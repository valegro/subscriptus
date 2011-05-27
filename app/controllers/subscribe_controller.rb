class SubscribeController < ApplicationController
  layout 'signup', :except => :invoice

  before_filter :load_subscription_from_session,    :only   => [ :thanks, :invoice, :complete ]
  before_filter :load_subscription_from_for,        :only   => [ :edit, :update ]
  before_filter :load_offer_and_publication,        :except => [ :thanks, :complete ]
  before_filter :load_source,                       :except => [ :thanks, :complete ]
  before_filter :load_gifts,                        :except => [ :thanks, :complete ]
  before_filter :load_tab,                          :except => [ :thanks, :complete ]
  before_filter :require_user,                      :only => [ :edit, :update ]
  before_filter :load_user,                         :only => [ :edit, :update ]

  rescue_from(Exceptions::PaymentFailedException, Exceptions::GiftNotAvailable, Exceptions::CannotStoreCard) do |exception|
    Rails.logger.info("Payment Failed")
    @subscription ||= @factory.try(:subscription) # Ensure that the subscription instance is set
    flash[:error] = exception.message
    render :action => :new
  end

  rescue_from(Exceptions::Factory::InvalidException) do |exception|
    @subscription = exception.subscription
    @errors = exception.errors
    @payment = Payment.new(params[:payment])
    render :action => :new
  end

  rescue_from(ActiveRecord::RecordInvalid) do |exception|
    Rails.logger.info("Record Invalid #{exception.inspect}")
    @subscription ||= Subscription.new(params[:subscription])
    @errors = exception.record.errors
    @payment ||= Payment.new(params[:payment])
    render :action => :new
  end

  def new
    clear_session
    @payment = Payment.new
    @subscription = Subscription.new
    @user = @subscription.build_user(:title => 'Mr', :state => :act)
    @subscription.offer = @offer
  end

  def create
    @payment_option = params[:payment_option]
    Subscription.transaction do
      # First check if a user exists with the given email
      @user = User.find_by_email(params[:user].try(:[], :email))
      if @user
        @subscription = @user.subscriptions.first(
          :conditions => { :publication_id => @offer.publication.id }
        )
        if !@subscription.trial? && !@subscription.squatter?
          redirect_to new_renew_path(:offer_id => @offer, :source_id => @source)
          return
        end
      end
      @user ||= User.new(params[:user])
      @user.rollback_active_record_state! do
        if @user
          @user.update_attributes!(params[:user])
        else
          @user.save!
        end
        @factory = get_factory
        @subscription = @subscription ? @factory.update(@subscription) : @factory.build
      end
      store_subscription_in_session
      redirect_to thanks_path
    end
  end

  def edit
    clear_session
    @renewing = true
    @subscription ||= @user.subscriptions.find(:first, :conditions => { :publication_id => @offer.publication.id })
    @subscription ||= Subscription.new

    # Ensure we have a valid offer
    @user.email_confirmation = @user.email
    render :template => 'subscribe/new'
  end

  def update
    @renewing = true
    @payment_option = params[:payment_option]
    # See if we have an existing subscription
    @subscription = @user.subscriptions.find(:first, :conditions => { :publication_id => @offer.publication.id })


    Subscription.transaction do
      @user.update_attributes!(params[:user])
      @factory = get_factory
      @subscription = @subscription.blank? ? @factory.build : @factory.update(@subscription)
      if @for
        flash[:notice] = "Successfully renewed subscription"
        redirect_to admin_subscription_path(@subscription)
      else
        store_subscription_in_session
        redirect_to thanks_path
      end
    end
  end

  def thanks
    @has_weekender = @subscription.user.has_weekender?
  end

  def complete
    @subscription.update_attributes!(params[:subscription])
    if params[:weekender]
      @user = @subscription.user
      @user.add_weekender_to_subs
    end
    clear_session
  end

  def invoice
    @user = @subscription.user
  end

  private
    def get_factory
      SubscriptionFactory.new(@offer, {
        :attributes         => params[:subscription].merge(:user => @user),
        :term_id            => params[:offer_term],
        :optional_gift      => params[:optional_gift],
        :included_gift_ids  => params[:included_gifts].try(:map, &:to_i),
        :payment_attributes => params[:payment],
        :concession         => params[:concession],
        :source             => params[:source_id],
        :payment_option     => @payment_option
      })
    end

    def load_subscription_from_session
      if session[:subscription_id]
        @subscription = Subscription.find(session[:subscription_id])
      end
    end

    def load_subscription_from_for
      if current_user && current_user.admin? && @for = params[:for]
        @subscription = Subscription.find(params[:for])
      end
    end

    def load_offer_and_publication
      @offer = if params[:offer_id]
        Offer.find(params[:offer_id])
      end
      @publication = if params[:publication_id]
        Publication.find(params[:publication_id])
      end
      @publication = @subscription.publication if @subscription

      if !@offer && @publication
        @offer = (@publication.offers.default_for_renewal || @publication.offers.first)
      end
      if !@offer
        @offer = Offer.primary_offer
      end
    end

    def load_source
      @source = (params[:source_id] && params[:source_id] != 'null') ? Source.find(params[:source_id]) : nil
    end

    def load_tab
      @tab = params[:tab] || 'subscriptions'
      if !%w(subscriptions students groups concessions).include?(@tab) || @offer.offer_terms.concession.empty?
        @tab = 'subscriptions'
      end
      @direct_debit_allowed = (@tab == 'subscriptions')
    end

    def load_gifts
      @included_gifts = @offer.gifts.in_stock.included
      if @offer.gifts.in_stock.optional.size == 1
        @included_gifts.concat(@offer.gifts.in_stock.optional)
        @optional_gifts = []
      else
        @optional_gifts = @offer.gifts.in_stock.optional
      end
    end

    def store_subscription_in_session
      session[:subscription_id] = @subscription.try(:id)
    end

    def clear_session
      session[:subscription_id] = nil
    end

    def load_user
      if current_user.admin?
        if (@subscription)
          @user = @subscription.user
          # We also need a list of the available offers if we are renewing for someone else
          @offers = Offer.for_publication(@offer.publication_id)
        else
          redirect_to admin_subscriptions_path
          return
        end
      else
        @user = current_user
      end
    end

end

class SubscribeController < ApplicationController
  layout 'signup', :except => :invoice
  before_filter :load_offer_and_publication,  :except => [ :thanks, :complete ]
  before_filter :load_source,                 :except => [ :thanks, :complete ]
  before_filter :load_gifts,                  :except => [ :thanks, :complete ]
  before_filter :load_tab,                    :except => [ :thanks, :complete ]

  before_filter :load_subscription, :only => [ :thanks, :complete, :invoice ]
  before_filter :require_user, :only => [ :edit, :update ]

  rescue_from(Exceptions::PaymentFailedException, Exceptions::GiftNotAvailable) do |exception|
    Rails.logger.info("Payment Failed")
    @subscription ||= @factory.try(:subscription) # Ensure that the subscription instance is set
    flash[:error] = exception.message
    render :action => :new
  end

  # TODO: Will this ever get called again?
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
      @user = User.new(params[:user])
      @user.save!
      @factory = get_factory
      @subscription = @factory.build
      store_subscription_in_session
      redirect_to thanks_path
    end
  end

  def edit
    clear_session
    @user = current_user
    @subscription = @user.subscriptions.find(:first, :conditions => { :publication_id => @offer.publication.id })
    @subscription ||= Subscription.new
    # Ensure we have a valid offer
    @user.email_confirmation = @user.email
    @renewing = true
    render :template => 'subscribe/new'
  end

  def update
    @payment_option = params[:payment_option]
    @user = current_user
    # See if we have an existing subscription
    # TODO: Dry this up (see new)
    @subscription = @user.subscriptions.find(:first, :conditions => { :publication_id => @offer.publication.id })

    Subscription.transaction do
      @user.update_attributes!(params[:user])
      @factory = get_factory
      @subscription = @subscription.blank? ? @factory.build : @factory.update(@subscription)
      store_subscription_in_session
      redirect_to thanks_path
    end
  end

  def thanks
  end

  def complete
    @subscription.update_attributes!(params[:subscription])
    @weekender = Publication.find_by_name("Crikey Weekender")
    if params[:weekender] && @weekender
      @user = @subscription.user
      @user.subscriptions.create!(
        :publication => @weekender,
        :offer => @subscription.offer,
        :state => 'active',
        :expires_at => nil
      )
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

    def load_offer_and_publication
      @offer = if params[:offer_id]
        Offer.find(params[:offer_id])
      end
      @publication = if params[:publication_id]
        Publication.find(params[:publication_id])
      end
      if !@offer && @publication
        @offer = (@publication.offers.default_for_renewal || @publication.offers.first)
      end
      if !@offer
        @offer = Offer.first
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

    def load_subscription
      @subscription = Subscription.find(session[:subscription_id])
    end
end

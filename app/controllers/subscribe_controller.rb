class SubscribeController < ApplicationController
  layout 'signup'
  before_filter :load_offer
  before_filter :load_source
  before_filter :load_gifts
  before_filter :load_tab

  rescue_from(Exceptions::PaymentFailedException, Exceptions::GiftNotAvailable) do |exception|
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
    # TODO: This seems hacky!
    @subscription ||= Subscription.new(params[:subscription])
    @errors = exception.record.errors
    @payment ||= Payment.new(params[:payment])
    render :action => :new
  end

  def new
    @payment = Payment.new

    #@user = User.subscribers.first # TODO: Use current user
    if @user
      @subscription = @user.subscriptions.find(:first, :conditions => { :publication_id => @offer.publication.id })
      @user.email_confirmation = @user.email
    end
    @subscription ||= Subscription.new
    @user ||= @subscription.build_user(:title => 'Mr', :state => :act)
    @subscription.offer = @offer

    if params[:email]
      # TODO: Display login form prepopulated with email unless @user is an existing user (current_user)
    end
  end

  def create
    @payment_option = params[:payment_option]
    Subscription.transaction do
      @user = User.new(params[:user])
      @user.save!
      @factory = get_factory
      @subscription = @factory.build
      redirect_to :action => :thanks
    end
  end

  def update
    @payment_option = params[:payment_option]

    @user = User.subscribers.first # TODO: Use current user
    # See if we have an existing subscription
    # TODO: Dry this up (see new)
    @subscription = @user.subscriptions.find(:first, :conditions => { :publication_id => @offer.publication.id })

    Subscription.transaction do
      @user.update_attributes!(params[:user])
      @factory = get_factory
      @subscription = @subscription.blank? ? @factory.build : @factory.update(@subscription)
      redirect_to :action => :thanks
    end
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

    def load_offer
      @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
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
end

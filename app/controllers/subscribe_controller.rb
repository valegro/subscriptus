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

  rescue_from(Exceptions::Factory::InvalidException) do |exception|
    @subscription = exception.subscription
    @errors = exception.errors
    @payment = Payment.new(params[:payment])
    render :action => :new
  end

  def new
    @subscription = Subscription.new
    @subscription.offer = @offer
    @payment = Payment.new
    if params[:email]
      @user = User.find_by_email(params[:email]) # TODO: And Wordpress exists??
      if @user && @user.has_active_subscriptions?
        @subscription.user = @user
      end
    end
    @user ||= @subscription.build_user(:title => 'Mr', :state => :act)
  end

  def create
    @payment_option = params[:payment_option]
    Subscription.transaction do
      @factory = SubscriptionFactory.new(@offer, {
        :term_id            => params[:offer_term],
        :optional_gift      => params[:optional_gift],
        :included_gift_ids  => params[:included_gifts].try(:map, &:to_i),
        :attributes         => params[:subscription],
        :payment_attributes => params[:payment],
        :concession         => params[:concession],
        :source             => params[:source_id],
        :payment_option     => @payment_option
      })
      @subscription = @factory.build
      redirect_to :action => :thanks
    end
  end

  private
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

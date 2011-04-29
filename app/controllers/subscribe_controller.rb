class SubscribeController < ApplicationController
  layout 'signup'
  before_filter :load_offer
  before_filter :load_gifts

  rescue_from(Exceptions::PaymentFailedException, Exceptions::GiftNotAvailable) do |exception|
    @subscription ||= @factory.try(:subscription) # Ensure that the subscription instance is set
    flash[:error] = exception.message
    render :action => :new
  end

  rescue_from(ActiveRecord::RecordInvalid) do |exception|
    render :action => :new
  end

  def new
    source = (params[:source_id] && params[:source_id] != 'null') ? Source.find(params[:source_id]) : nil
    @subscription = Subscription.new
    @subscription.offer = @offer
    @subscription.source = source
    if params[:delivered_to]
      # TODO: Spec
      @user = User.find_by_email(params[:delivered_to])
      if @user && @user.has_active_subscriptions?
        @subscription.user = @user
      end
    end
    @user ||= @subscription.build_user(:title => 'Mr', :state => :act)
    @subscription.payments.build
  end

  def create
    Subscription.transaction do
      @factory = SubscriptionFactory.new(@offer, {
        :term_id            => params[:offer_term],
        :optional_gift      => params[:optional_gift],
        :included_gift_ids  => params[:included_gifts].try(:map, &:to_i),
        :attributes         => params[:subscription],
        :payment_attributes => params[:payment]
      })
      @subscription = @factory.build
      @subscription.save!
      redirect_to :action => :thanks
    end
  end

  private
    def load_offer
      @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
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

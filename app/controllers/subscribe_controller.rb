class SubscribeController < ApplicationController
  layout 'signup'

  def new
    # TODO: We can clean this code up a bit
    @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
    source = (params[:source_id] && params[:source_id] != 'null') ? Source.find(params[:source_id]) : nil
    @optional_gifts = @offer.gifts.in_stock.optional
    @included_gifts = @offer.gifts.in_stock.included
    @subscription = Subscription.new
    # TODO: Accepts nested attributes for offer and source??
    @subscription.offer = @offer
    @subscription.source = source
    @subscription.subscription_gifts.build(:gift => @optional_gifts.first)
    @subscription.build_user
    @subscription.payments.build
  end

  def create
    @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
    @subscription = Subscription.new(params[:subscription])
    @subscription.use_offer(@offer)
    if @subscription.save_in_transaction
      redirect_to :action => :thanks
    else
      render :action => :new
    end
  end
end

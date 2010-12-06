class SubscribeController < ApplicationController
  layout 'signup'
  before_filter :load_offer
  before_filter :load_gifts

  def new
    source = (params[:source_id] && params[:source_id] != 'null') ? Source.find(params[:source_id]) : nil
    @subscription = Subscription.new
    # TODO: Accepts nested attributes for offer and source??
    @subscription.offer = @offer
    @subscription.source = source
    @subscription.subscription_gifts.build(:gift => @optional_gifts.first)
    @subscription.build_user
    @subscription.payments.build
  end

  def create
    @term = params[:offer_term] ? OfferTerm.find(params[:offer_term]) : @offer.offer_terms.first
    @subscription = Subscription.new(params[:subscription])
    # Set to active because we are taking payment
    @subscription.state = 'active'
    @subscription.use_offer(@offer, @term)
    if @subscription.save_in_transaction
      redirect_to :action => :thanks
    else
      render :action => :new
    end
  end

  private
    def load_offer
      @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
    end

    def load_gifts
      @optional_gifts = @offer.gifts.in_stock.optional
      @included_gifts = @offer.gifts.in_stock.included
    end
end

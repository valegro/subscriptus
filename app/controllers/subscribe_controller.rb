class SubscribeController < ApplicationController
  act_wizardly_for :subscription, :form_data => :sandbox, :canceled => "/" #, :persist_model => :once

  def index
    redirect_to :action => :offer, :offer_id => params[:offer_id], :source_id => params[:source_id]
  end

  on_get(:offer) do
    @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
    @optional_gifts = @offer.gifts.in_stock.optional
    @included_gifts = @offer.gifts.in_stock.included
    @subscription.offer = @offer
    @subscription.subscription_gifts.clear
    @subscription.subscription_gifts.build(:gift_id => @optional_gifts.first)
  end

  on_next(:offer) do
    @offer = Offer.find(params[:subscription][:offer_id])
    @ot = params[:offer_term] ? OfferTerm.find(params[:offer_term]) : @offer.offer_terms.first
    @subscription.price = @ot.price
    @subscription.expires_at = @ot.months.months.from_now
  end

  on_cancel(:all) do
    @subscription.destroy
  end
end

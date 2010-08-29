class SubscribeController < ApplicationController
  act_wizardly_for :subscription

  def index
    redirect_to :action => :offer, :offer_id => params[:offer_id], :source_id => params[:source_id]
  end

  on_get(:offer) do
    @offer = Offer.find(params[:offer_id])
  end
end

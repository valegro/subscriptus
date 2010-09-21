class SubscribeController < ApplicationController
  layout 'admin'

  act_wizardly_for :subscription, :form_data => :sandbox, :canceled => "/", :completed => "/", :persist_model => :once

  def index
    redirect_to :action => :offer, :offer_id => params[:offer_id], :source_id => params[:source_id]
  end

  on_get(:offer) do
    @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
    @optional_gifts = @offer.gifts.in_stock.optional
    @included_gifts = @offer.gifts.in_stock.included
    @subscription.offer = @offer
    @subscription.subscription_gifts.clear
    @subscription.subscription_gifts.build(:gift => @optional_gifts.first)
  end

  on_next(:offer) do
    @offer = Offer.find(params[:subscription][:offer_id])
    @ot = params[:offer_term] ? OfferTerm.find(params[:offer_term]) : @offer.offer_terms.first
    @subscription.price = @ot.price
    @subscription.expires_at = @ot.months.months.from_now
    @subscription.gifts.add_uniquely(@offer.available_included_gifts)
  end

  on_get(:details) do
    # TODO: Check current user here - if logged in skip
    @user = @subscription.build_user(session[:user_dat])
    @user.country ||= 'Australia'
  end

  on_next(:details) do
    @new_or_existing = params[:new_or_existing]
    if @new_or_existing == 'new'
      session[:user_dat] = @subscription.user.attributes
      session[:user_dat][:email_confirmation] = @subscription.user.email_confirmation
      unless @subscription.user.valid?
        flash[:notice] = @subscription.errors.full_messages
        render :action => :details
      end
    else
      user_session = UserSession.new(:login => @subscription.user.login, :password => @subscription.user.password)
      session[:user_dat] = nil
      @user = @subscription.build_user
      unless user_session.save
        flash[:notice] = "Invalid login name or password"
        render :action => :details
      end
    end
  end

  on_next(:payment) do
    puts "AAAA"
    # TODO: Check gateway here
  end

  on_cancel(:all) do
    @subscription.destroy
  end

  on_finish(:payment) do
    puts "HERE"
    @subscription.build_user(session[:user_dat])
    @subscription.update_attributes(params[:subscription])
    @subscription.user.save!
    session[:user_dat] = nil
  end
end

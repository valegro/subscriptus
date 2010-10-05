class SubscribeController < ApplicationController
  layout 'admin'

  act_wizardly_for :subscription, :form_data => :sandbox, :canceled => "/", :completed => "/", :persist_model => :once

# delayed_job , atomic:
# begin
#   subscription => campaign_master flag = pending
#   call delayed_job
#   subscription => campaign_master flag = done
# rescue timeout
# rescue error
# end

  around_filter :catch_exceptions

  act_wizardly_for :subscription, :form_data => :sandbox, :canceled => "/", :persist_model => :once, :guard => false
  
#TODO: fix gaurd issue.  only non-guard the offer page

  # the link of offer is clicked
  # gaurd should be false, otherwise parameters are not instantiated
  def index
    redirect_to :action => :offer, :offer_id => params[:offer_id], :source_id => params[:source]
  end

  on_get(:offer) do
    @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
    @optional_gifts = @offer.gifts.in_stock.optional
    @included_gifts = @offer.gifts.in_stock.included
    @subscription.offer = @offer
    # @subscription.gifts.clear
    # @subscription.gifts << @optional_gifts.first # by default the first one is selected which can be changed by the user
    @subscription.subscription_gifts.clear
    @subscription.subscription_gifts.build(:gift => @optional_gifts.first)
  end

  on_next(:offer) do
    # adding user selected optional gifts
    begin
      @subscription.gifts.add_uniquely_one(Gift.find(params[:subscription][:subscription_gifts_attributes]["0"]["gift_id"]))
    rescue Exception => e
      logger.error("param doesnt exit")
    end
    @offer = Offer.find(@subscription.offer.id)
    @ot = params[:offer_term] ? OfferTerm.find(params[:offer_term]) : @offer.offer_terms.first
    @subscription.price = @ot.price
    @subscription.expires_at = @subscription.get_new_expiry_date(@ot.months) # new subscription starts after the finish date of current subscription/trial
    @subscription.gifts.add_uniquely(@offer.available_included_gifts)
  end

  on_get(:details) do
    @user = @subscription.build_user(session[:user_dat])  # this session is set in on_next(:details) for later visits
    @user.country ||= 'Australia'
    @subscription.user_id = @user.id  # weird! we need this line as build doesnt set user_id
  end

  on_next(:details) do
    session[:new_user] = params[:new_or_existing] == 'new' # session[:new_user] is used later when ending the wizard
    session[:user_dat] = @subscription.user.attributes

    if session[:new_user]
      session[:user_dat]["password"] = @subscription.user.password
      session[:user_dat]["password_confirmation"] = @subscription.user.password_confirmation
      session[:user_dat]["email_confirmation"] = @subscription.user.email_confirmation

      unless @subscription.user.valid?
        # any type of offer(trial/full subscription), invalid new user
        flash[:error] = @subscription.errors.full_messages
        render :action => :details
      end
    else
      user_session = UserSession.new(:login => @subscription.user.attributes["login"], :password => params[:subscription][:user_attributes][:password]) # user's password is set to blank
      session[:user_dat] = nil
      if user_session.save
        # valid login details
        @subscription.user = User.find_by_login(@subscription.user.attributes["login"]) # only if user_session is correctly saved
      else
        # invalid login details
        # any type of offer(trial/full subscription), invalid existing user
        flash[:error] = "Invalid login name or password"
        render :action => :details
      end
    end

    # if the offer is a trial, skip payment and
    # FINISH the wizard
    # otherwise just o to the next page of wizard(payment)
    if @subscription.offer.is_trial?
      # subscription should be saved in database before the wizard is finished so that no conflicts happens between has_states and wizardly
      # the first subscription has a trial state
      @subscription = Subscription.create(@subscription.attributes)
      # because of the belongs_to assosiation, user needs to be saved seperately only if user is new.
      if session[:new_user]
        # new user
        @subscription.user = save_new_user(session[:user_dat])
      end
      # finish the wizard
      @subscription.save
      flash[:notice] = "Congratulations! Your trial subscribtion was successful."
      redirect_to(:action => :offer)
    end
  end

  on_get(:payment) do
    @payment = Payment.new
  end

  on_finish(:payment) do
    # subscription should be saved in database before the wizard is finished so that no conflicts happens between has_states and wizardly
    # the first subscription has a trial state
    @subscription = Subscription.create(@subscription.attributes)

    @payment = Payment.new() # Payment is not an active record
    @payment.card_verification  = params[:payment]["card_verification"]
    @payment.card_type          = params[:payment]["card_type"]
    expiry_date = "#{params[:payment]['card_expires_on(1i)']}-#{params[:payment]['card_expires_on(2i)']}-#{params[:payment]['card_expires_on(3i)']}"
    @payment.card_expires_on = Date.strptime(expiry_date, '%Y-%m-%d')
    @payment.card_number        = params[:payment]["card_number"]
    @payment.last_name          = params[:payment]["last_name"]
    @payment.first_name         = params[:payment]["first_name"]

    @payment.money = @subscription.price    # setting the money of payment object

    # because of the belongs_to assosiation, user needs to be saved seperately only if user is new.
    if session[:new_user]
      # new user
      @subscription.user = save_new_user(session[:user_dat])
    end
    @payment.customer_id = @subscription.generate_recurrent_profile_id # setting the options details(customer) of payment object
    
    # call set up recurrent profile
    setup_res = @payment.create_recurrent_profile
    if setup_res.success?
      # recurrent setup successul
      trigger_res = @payment.call_recurrent_profile
      if trigger_res.success?
        # recurrent trigger successul
        @subscription.recurrent_id = @payment.customer_id

        # customer_id of the payment must be set first
        # change the state of subscription from trial to active
        @subscription.activate
        
        flash[:notice] = "Congratulations! Your subscribtion was successful."
        redirect_to(:action=>:offer)
      else
        # recurrent trigger failed
        flash[:error] = "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
        redirect_to(:action=>:offer)
      end
    else
      # recurrent setup failed.
      flash[:error] = "Unfortunately your payment was not successfull. Please check your credit card details and try again."
      render(:action => :payment)
    end
  end

  on_cancel(:all) do
    @subscription.destroy
  end

  private

  # creates or updates the user
  # returns user
  def save_new_user(user_attributes)
    user = User.new(user_attributes)
    user.save!
    return user
  rescue Exception => e
    raise Exceptions::UserInvalid.new(e.message)
  end
  
  def catch_exceptions
    yield
  rescue Exceptions::UserInvalid => e
    logger.error("Exceptions::UserInvalid ---> " + e.message)
    flash[:error] = "Unfortunately your payment was not successfull. Please try again later. There might be some problems with the cookies of your web browser."
    # redirect_to(:action=>:offer)
  rescue Exceptions::TriggerRecurrentProfileNotSuccessful => e
    # triggering recurrent failed
    logger.error("Exceptions::TriggerRecurrentProfileNotSuccessful ---> " + e.message)
    flash[:error] = "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
    redirect_to(:action=>:offer)
  rescue Exceptions::CreateRecurrentProfileNotSuccessful => e
    # setting up new recurrent profile failed
    logger.error("Exceptions::CreateRecurrentProfileNotSuccessful ---> " + e.message)
    flash[:error] = "Unfortunately your payment was not successfull. Please check your credit card details and try again."
    redirect_to(:action=>:offer)
  rescue Exceptions::ZeroAmount => e
    logger.error("Exceptions::ZeroAmount ---> " + e.message)
    flash[:error] = "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
    redirect_to(:action=>:offer)
  rescue Exception => e
    # Credit card may be invalid.
    logger.error("Exception ---> " + e.message)
    flash[:error] = "Unfortunately your payment was not successfull. Something went wrong during your subscription."
    flash[:notice] = "Unfortunately your payment was not successfull. Something went wrong during your subscription."
    redirect_to(:action=>:offer)
  end
end
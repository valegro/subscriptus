class S::SubscriptionsController < SController
  around_filter :catch_exceptions
  
  def index
    @subscriptions = current_user.subscriptions
  end
  
  # Choose the payment method paying for the subscription
  def payment
    @payment = Payment.new
    raise Exceptions::UnableToFindSubscription unless params[:id] && current_user && current_user.subscriptions.find(params[:id])
    session[:subscription] = current_user.subscriptions.find(params[:id])
    @name = session[:subscription].publication ? session[:subscription].publication.name : "No Publication"
    # if session[:subscription].blank?
    #   #FIXME: refactor
    #   flash[:error] = "Unable to pay for this subscription"
    #   redirect :action => :index
    # end
    # user chooses their payment method
  end

  def pay
    @subscription = session[:subscription]
    session[:subscription] = nil
    
    case params[:payment_method]
    when "credit_card"
      # make the payment using Credit Card details
      @payment = Payment.new() # Payment is not an active record
      @payment.card_verification = params[:payment]["card_verification"]
      @payment.card_type = params[:payment]["card_type"]
      expiry_date = "#{params[:payment]['card_expires_on(1i)']}-#{params[:payment]['card_expires_on(2i)']}-#{params[:payment]['card_expires_on(3i)']}"
      @payment.card_expires_on = Date.strptime(expiry_date, '%Y-%m-%d')
      @payment.card_number = params[:payment]["card_number"]
      @payment.last_name = params[:payment]["last_name"]
      @payment.first_name = params[:payment]["first_name"]
      @payment.money = @subscription.price # setting the money of payment object

      if current_user.recurrent_id.blank?
        @payment.customer_id = current_user.generate_recurrent_profile_id
        # call set up recurrent profile
        setup_successful = @payment.create_recurrent_profile.success?
      else
        @payment.customer_id = current_user.recurrent_id
        # no need to call set up recurrent profile
        setup_successful = true
      end

      if setup_successful
        @payment.order_num = @subscription.generate_and_set_order_number # order_num is sent to the user as a reference number of their subscriptions
        # recurrent setup successul
        @subscription.user.recurrent_id = @payment.customer_id # now user has a valid profile in secure pay that can be refered to by their recurrent_id
        trigger_res = @payment.call_recurrent_profile # make the payment through secure pay
        if trigger_res.success?
          # recurrent trigger successul
          # customer_id of the payment must be set first
          # change the state of subscription from trial to active
          @subscription.activate
          # FINISHING THE WIZARD
          flash[:notice] = "Congratulations! Your subscription was successful."
          redirect_to :action => :index
        else
          # recurrent trigger failed
          logger.error("Exception In s/Subscriptions Controller ..... trigger_res: #{trigger_res}")
          raise Exceptions::TriggerRecurrentProfileNotSuccessful.new("from s_subscriptions_controller")
        end
      else
        # recurrent setup failed.
        logger.error("Exception In s/Subscriptions Controller ..... setup_successful: #{setup_successful}")
        raise Exceptions::CreateRecurrentProfileNotSuccessful.new("from s_subscriptions_controller")
      end

    when "direct_debit"
      # Direct Debit payments
      # change the state of subscription from trial to pending -- but do this after the current expiration date
      @subscription.pay_later
      @subscription.save!
      session[:subscriber_full_name] = "#{@subscription.user.firstname} #{@subscription.user.lastname}"
      redirect_to :action => :direct_debit
    end
  end
  
  # to pay by direct debit
  def direct_debit
    @name = session[:subscriber_full_name]
    session[:subscriber_full_name] = nil
  end
  
  def download_pdf
    raise Exceptions::InvalidName.new("invalid pdf file name") unless params[:kind] == "credit" || params[:kind] == 'bank'
    send_file "#{RAILS_ROOT}/public/pdfs/crikey_directdebit_#{params[:kind]}.pdf", :type => 'application/pdf'
  end

  # # to pay by credit card
  # def credit_card
  #   if current_user.has_secure_pay_account
  #     # User already has a valid secure_pay account referenced by their recurrent_id
  #   else
  #     # User doesnt have a secure_pay account
  #     render :action => :credit_card
  #   end
  # end

  private
  
  def catch_exceptions
      yield
    rescue Exceptions::UnableToFindSubscription => e
      logger.error("Exceptions::UnableToFindSubscription ---> " + e.message)
      flash[:error] = "Chosen subscription is invalid!"
      redirect_to :action=>:index
    rescue Exceptions::TriggerRecurrentProfileNotSuccessful => e
      # triggering recurrent failed
      logger.error("Exceptions::TriggerRecurrentProfileNotSuccessful ---> " + e.message)
      flash[:error] = "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
      redirect_to :action => :index
    rescue Exceptions::CreateRecurrentProfileNotSuccessful => e
      # setting up new recurrent profile failed
      logger.error("Exceptions::CreateRecurrentProfileNotSuccessful ---> " + e.message)
      flash[:error] = "Unfortunately your payment was not successfull. Please check your credit card details and try again."
      redirect_to :action => :index
    rescue Exceptions::ZeroAmount => e
      logger.error("Exceptions::ZeroAmount ---> " + e.message)
      flash[:error] = "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
      redirect_to :action => :index
    rescue Exception => e
      logger.error("General Exception ---> " + e.message)
      flash[:error] = "Unfortunately your payment was not successfull. Something went wring during your subscription."
      redirect_to :action => :index
  end
end

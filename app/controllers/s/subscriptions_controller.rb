class S::SubscriptionsController < SController
  include S::SubscriptionsHelper
  
  rescue_from Exception, :with => :show_errors
  rescue_from Exceptions::CreateRecurrentProfileNotSuccessful, :with => :invalid_card_details
  rescue_from Exceptions::CanNotBePaidFor, Exceptions::CanNotBeCanceled, :with => :invalid_status
  
  before_filter :find_subscription, :only => [:payment, :pay, :direct_debit, :cancel]
  
  def index
    @subscriptions = current_user.subscriptions
  end
  
  # Choose the payment method paying for the subscription
  def payment
    raise Exceptions::CanNotBePaidFor unless can_be_paid_for(@subscription.state)
    @payment = Payment.new
  end

  def pay
    case params[:payment_method]
    when "existing_credit_card"
      # New user tries to use existing credit card option!
      raise Exceptions::CreateRecurrentProfileNotSuccessful unless @subscription.user.has_recurrent_profile?
      payment = Payment.new
      @subscription.pay_non_first_time(payment)
      flash[:notice] = "Congratulations! Your subscription was successful using your existing Credit Card details."
      redirect_to :action => :index
    when "new_credit_card"
      # make the payment using Credit Card details
      payment = Payment.new() # Payment is not an active record
      payment.card_verification = params[:payment]["card_verification"]
      payment.card_type = params[:payment]["card_type"]
      expiry_date = "#{params[:payment]['card_expires_on(1i)']}-#{params[:payment]['card_expires_on(2i)']}-#{params[:payment]['card_expires_on(3i)']}"
      payment.card_expires_on = Date.strptime(expiry_date, '%Y-%m-%d')
      payment.card_number = params[:payment]["card_number"]
      payment.last_name = params[:payment]["last_name"]
      payment.first_name = params[:payment]["first_name"]

      @subscription.pay_first_time(payment)
      flash[:notice] = "Congratulations! Your subscription was successful using your new Credit Card details."
      redirect_to :action => :index
    when "direct_debit"
      # Direct Debit payments
      # change the state of subscription from trial to pending -- but do this after the current expiration date
      @subscription.pay_later
      @subscription.save!
      redirect_to direct_debit_s_subscription_path(@subscription)
    end
  end
  
  # to pay by direct debit
  def direct_debit
  end
  
  def download_pdf
    raise Exceptions::InvalidName.new("invalid pdf file name") unless params[:kind] == "credit" || params[:kind] == 'bank'
    send_file "#{RAILS_ROOT}/public/pdfs/crikey_directdebit_#{params[:kind]}.pdf", :type => 'application/pdf'
  end

  def cancel
    raise Exceptions::CanNotBeCanceled unless can_be_canceled(@subscription.state)
    @subscription.cancel
    flash[:error] = "You have successfully canceled your subscription."
    redirect_to :action=>:index
  end

  protected
  
  def show_errors(exception)
    logger.error(exception.message)
    flash[:error] = "Unfortunately something went wrong. Please try again later."
    redirect_to :action=>:index
  end
  
  def invalid_card_details(exception)
    logger.error(exception.message)
    flash[:error] = "You do not have any profile in Secure Pay. Please fill in your new Credit Card details."
    redirect_to :action=>:index
  end
  
  def invalid_status(exception)
    logger.error(exception)

    if exception.is_a?(Exceptions::CanNotBePaidFor)
      flash[:error] = "You can not pay for this subscription. You may have already chosen another method of payment. Please follow your previous method of payment or contact Crikey for further information."
    elsif exception.is_a?(Exceptions::CanNotBeCanceled)
      flash[:error] = "You can not cancel this subscription. Please contact Crikey for further information."
    end

    redirect_to :action=>:index
  end

  private
  
  def find_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  end
end

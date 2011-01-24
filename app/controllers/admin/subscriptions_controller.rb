class Admin::SubscriptionsController < AdminController
  layout 'admin/subscriptions'
  include Admin::SubscriptionsHelper
  
  before_filter :find_subscription, :only => [ :verify, :cancel ]

  def index
    @log_entries = SubscriptionLogEntry.recent.paginate(:page => params[:page] || 1)
  end

  def search
    if params[:search] && params[:search].has_key?(:id)
      params[:search][:id] = Subscription.id_from_reference(params[:search][:id])
    end
    @search = Subscription.search(params[:search])
    
    @search.class.send :attr_accessor, :renewal   # TODO: renewal search
    @search.class.send :attr_accessor, :gift      # TODO: gift search
    @results, @count = @search.all.paginate(:page => params[:page], :per_page => Subscription.per_page), @search.count
  end

  def pending
    @subscriptions = Subscription.pending.paginate(:page => params[:page], :per_page => Subscription.per_page, :order => 'updated_at') 
  end

  def verify
    @payment = Payment.new(:amount => @subscription.price, :payment_type => 'direct_debit')
    if request.post?
      if params[:payment]
        @payment = Payment.new(params[:payment])
        @payment.amount = @subscription.price
        @subscription.verify!(@payment)
        # TODO: Validations? Exceptions?
      else
        @subscription.update_attributes(params[:subscription])
        @subscription.verify!
      end
      flash[:notice] = "Verified Subscription"
      redirect_to :action => :pending
    end
  end

  def cancel
    @subscription.cancel!
    flash[:notice] = "Subscription Canceled"
    redirect_to :action => :index
  end

  protected
  
  def find_subscription
    @subscription = Subscription.find(params[:id])
  end
end

class Admin::SubscriptionsController < AdminController
  layout 'admin/subscriptions'
  include Admin::SubscriptionsHelper
  
  before_filter :find_subscription, :only => [ :verify, :cancel, :suspend, :unsuspend ]

  def index
    @log_entries = SubscriptionLogEntry.recent.paginate(:page => params[:page] || 1)
  end

  def search

    if params[:search] && params[:search].has_key?(:id)
      params[:search][:id] = Subscription.id_from_reference(params[:search][:id])
    end
    @search = Subscription.search(params[:search])
    
    @search.class.send :attr_accessor, :renewal   # TODO: renewal search
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
  
  def suspend
    respond_to do |format|
      unless request.post?
        format.js {
          render :update do |page|
            page.insert_html :bottom, 'content', :partial => 'suspend_dialog'
            page['suspend-dialog'].dialog('open')
          end
        }
      else
        format.html {
        if period = params[:subscription][:state_expiry_period_in_days]
          @subscription.suspend!(period.to_i)
          flash[:notice] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} suspended for #{period} days"
          redirect_to :back
        end
        }
      end
    end
  end
  
  def unsuspend
    @subscription.unsuspend!
    flash[:notice] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} is now active"
    redirect_to :back
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

class Admin::SubscriptionsController < AdminController
  layout 'admin/subscriptions'
  helper 'admin'
  include Admin::SubscriptionsHelper
  
  before_filter :find_subscription, :only => [ :verify, :cancel, :suspend, :unsuspend, :show, :set_expiry, :unsubscribe ]

  rescue_from(Exceptions::PaymentTokenMissing) do
    flash[:error] = "The User has no payment gateway token - the payment will need to processed manually"
    render :action => action_name
  end

  rescue_from(Exceptions::PaymentFailedException) do
    flash[:error] = "The Subscriber's Card was declined. You may need to contact them."
    render :action => action_name
  end

  def index
    @log_entries = SubscriptionLogEntry.recent.paginate(:page => params[:page] || 1)
  end

  def show
    @log_entries = @subscription.log_entries.recent.paginate(:page => params[:page] || 1)
  end

  def search
    if params[:search] && params[:search].has_key?(:id)
      params[:search][:id] = Subscription.id_from_reference(params[:search][:id])
    end

    @search = Subscription.search(params[:search])
      
    @search.class.send :attr_accessor, :renewal   # TODO: renewal search
    unless params[:search].blank?
      @results, @count = @search.all.paginate(:page => params[:page], :per_page => Subscription.per_page), @search.count
    end
  end

  def pending
    @subscriptions = Subscription.pending.paginate(:page => params[:page], :per_page => Subscription.per_page, :order => 'updated_at') 
  end

  def unsubscribe
    @subscription.unsubscribe!
    flash[:notice] = "Unsubscribed successfully"
  rescue
    flash[:error] = "Already Unsubscribed"
  ensure
    redirect_to :action => :show
  end

  def verify
    @payment = @subscription.pending_action.try(:payment)
    if request.post? || request.put?
      unless @subscription.active?
        if params[:payment] && @payment
          @payment.update_attributes(params[:payment])
          @subscription.verify!
        else
          @subscription.update_attributes(params[:subscription])
          @subscription.verify!
        end
        flash[:notice] = "Verified Subscription"
      else
        flash[:error] = "Subscription has already been verified"
      end
      redirect_to :action => :pending
    end
  end

  def set_expiry
    respond_to do |format|
      unless request.post?
        format.js {
          render :update do |page|
            page.insert_html :bottom, 'content', :partial => 'set_expiry_dialog'
            page['set-expiry-dialog'].dialog('open')
          end
        }
      else
        format.html {
          if @subscription.update_attributes(params[:subscription])
            flash[:notice] = "Expiry date to #{@subscription.publication.name} for #{@subscription.user.name} set to #{format_timestamp(@subscription.expires_at)}"
          else
            flash[:error] = @subscription.errors.full_messages.join("<br/>")
          end
          redirect_to :action => :show
        }
      end
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
          unless @subscription.suspended?
            @subscription.suspend!(period.to_i)
            flash[:notice] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} suspended for #{period} days"
          else
            flash[:error] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} is already suspended!"
          end
          redirect_to :back
        end
        }
      end
    end
  end
  
  def unsuspend
    if @subscription.suspended?
      @subscription.unsuspend!
      flash[:notice] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} is now active"
    else
      flash[:error] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} is already active!"
    end
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

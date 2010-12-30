class Admin::SubscriptionsController < AdminController
  layout 'admin/subscriptions'
  include Admin::SubscriptionsHelper
  
  before_filter :find_subscription, :only => [ :mark_processed ]

  def index
    @log_entries = SubscriptionLogEntry.recent.paginate(:page => params[:page] || 1)
  end

  def list_cancelled
    @subscriptions = Subscription.find_all_by_state('cancelled').paginate(:page => params[:page], :per_page => Subscription.per_page, :order => 'updated_at')
  end
  
  def mark_processed
    @subscription.mark_processed
    @subscription.save!
    flash[:notice] = "You have successfully marked a subscription as processed. It now exists in Squattered subscriptions."
    redirect_to :action => :list_cancelled
  end

  def activitiy
  end

  def search
    @search = Subscription.search(params[:search])
    @search.class.send :attr_accessor, :renewal   # TODO: renewal search
    @search.class.send :attr_accessor, :gift      # TODO: gift search
    @results, @count = @search.all.paginate(:page => params[:page], :per_page => Subscription.per_page), @search.count
  end

  def pending
  end

  protected
  
  def find_subscription
    @subscription = Subscription.find(params[:id])
  end
end

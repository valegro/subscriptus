class Admin::SubscriptionsController < AdminController
  layout 'admin/subscriptions'
  include Admin::SubscriptionsHelper

  def index
  end

  def list_canceled
    @subscriptions = Subscription.find_all_by_state('active').paginate(:page => params[:page], :per_page => Subscription.per_page, :order => 'updated_at')
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
end

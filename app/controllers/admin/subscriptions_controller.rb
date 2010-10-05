class Admin::SubscriptionsController < AdminController
  include Admin::SubscriptionsHelper
  layout "subscriptions"

  def index
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

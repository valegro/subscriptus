class Admin::SubscribersController < AdminController
  layout 'admin/subscriptions'

  def show
    @subscriber = User.find(params[:id])
    @actions = @subscriber.actions.find(:all, sort_by_conditions).paginate(:page => params[:page], :per_page => 10)
    @subscriptions = @subscriber.subscriptions
  end
end

class Admin::SubscribersController < AdminController
  layout 'admin/subscriptions'

  def show
    @subscriber = User.find(params[:id])
  end
end

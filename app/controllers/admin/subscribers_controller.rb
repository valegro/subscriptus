class Admin::SubscribersController < AdminController
  layout 'admin/subscriptions'

  def show
    @subscriber = User.find(params[:id])
    @payments = @subscriber.payments.find(:all, sort_by_conditions).paginate(:page => params[:page], :per_page => 10)
  end
end

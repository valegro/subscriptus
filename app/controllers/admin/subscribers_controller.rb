class Admin::SubscribersController < AdminController
  layout 'admin/subscriptions'
  before_filter :find_subscriber

  def show
    @actions = [] # TODO: Fix this! @subscriber.actions.find(:all, sort_by_conditions).paginate(:page => params[:page], :per_page => 10)
    @subscriptions = @subscriber.subscriptions
  end

  def edit

  end

  def update
    @subscriber.update_attributes(params[:user])
    if @subscriber.save
      flash[:notice] = "Subscriber Details Updated"
      redirect_to :action => :show
    else
      render :action => :edit
    end
  end

  private
    def find_subscriber
      @subscriber = User.subscribers.find(params[:id])
    end
end

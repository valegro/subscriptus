class Admin::SubscribersController < AdminController
  layout 'admin/subscriptions'
  before_filter :find_subscriber

  def show
    @actions = SubscriptionAction.paginate(
      :conditions => { "subscriptions.user_id" => @subscriber.id },
      :joins => :subscription,
      :include => [:payment, :subscription],
      :order => "applied_at desc",
      :page => params[:page] || 1
    )
    @subscriptions = @subscriber.subscriptions
  end

  def edit

  end

  def update
    @subscriber.update_attributes(params[:user])
    if @subscriber.save
      flash[:notice] = "Subscriber Details Updated"
      @subscriber.sync_to_wordpress(@subscriber.password)
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

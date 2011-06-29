class Admin::SubscribersController < AdminController
  layout 'admin/subscriptions'
  before_filter :find_subscriber, :except => [ :new, :create ]

  rescue_from Wordpress::Error do |error|
    flash[:error] = "Wordpress Error: #{error.message}"
    notify_hoptoad(error)
    render :action => :edit
  end

  def new
    @subscriber = User.new(:role => 'subscriber')
  end

  def create
    @subscriber = User.new(params[:user])
    @subscriber.overide_wordpress = true
    @subscriber.role = :subscriber
    User.validate_as(:admin) do
      if @subscriber.save
        flash[:notice] = "Subscriber Details Updated"
        @subscriber.sync_to_wordpress(@subscriber.password)
        redirect_to admin_subscriber_path(@subscriber)
      else
        render :action => :new
      end
    end
  end

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

  def sync
    @subscriber.sync_to_wordpress
    @subscriber.sync_to_campaign_master
    flash[:notice] = "Synchronised User"
    redirect_to :action => :show
  end

  private
    def find_subscriber
      @subscriber = User.subscribers.find(params[:id])
    end
end

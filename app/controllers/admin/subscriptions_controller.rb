class Admin::SubscriptionsController < AdminController
  layout 'admin/subscriptions'
  helper 'admin'
  include Admin::SubscriptionsHelper
  
  before_filter :find_subscription, :only => [ :verify, :cancel, :suspend, :unsuspend, :show, :set_expiry, :unsubscribe, :activate ]
  before_filter :find_subscriber, :only => [ :new, :create ]
  before_filter :load_publications_and_states, :only => [ :new, :create ]

  rescue_from(Exceptions::PaymentTokenMissing) do
    flash[:error] = "The User has no payment gateway token - the payment will need to processed manually"
    render :action => action_name
  end

  rescue_from(Exceptions::PaymentFailedException) do
    flash[:error] = "The Subscriber's Card was declined. You may need to contact them."
    render :action => action_name
  end

  rescue_from(Exceptions::DuplicateSubscription) do
    flash.now[:error] = "The subscriber already has a subscription to that publication"
    @subscription = Subscription.new(params[:subscription])
    render :action => :new
  end

  def index
    @actions = SubscriptionAction.recent.paginate(:page => params[:page] || 1)
  end

  def show
    @log_entries = @subscription.log_entries.recent.paginate(:page => params[:page] || 1)
  end

  def new
    @subscription = @subscriber.subscriptions.build
  end

  def create
    @subscription = @subscriber.subscriptions.build(params[:subscription])
    if @subscription.save
      flash[:notice] = "Added subscription"
      redirect_to :action => :show, :id => @subscription.id
    else
      render :action => :new
    end
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
    @subscriptions = Subscription.any_pending.paginate(
      :page => params[:page],
      :per_page => Subscription.per_page,
      :order => 'updated_at'
    )
  end

  def unsubscribe
    @subscription.unsubscribe!
    flash[:notice] = "Unsubscribed successfully"
  rescue
    flash[:error] = "Already Unsubscribed"
  ensure
    redirect_to :action => :show
  end

  def activate
    @subscription.activate!
    flash[:notice] = "Activated Subscription"
    redirect_to admin_subscription_path(@subscription)
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
          suspension = ScheduledSuspension.new params[:scheduled_suspension]
          suspension.subscription_id = @subscription.id
          if suspension.start_date == Date.today
            if period = suspension.duration
              unless @subscription.suspended?
                @subscription.suspend!(period.to_i)
                flash[:notice] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} suspended for #{period} days"
              else
                flash[:error] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} is already suspended!"
              end
            end
          elsif suspension.start_date < Date.today
            flash[:error] = "Cannot schedule a suspension in the past."
          elsif suspension.duration < 1
            flash[:error] = "Cannot schedule a suspension for less than one day."
          else
            if suspension.save
              flash[:notice] = "Subscription to #{@subscription.publication.name} for #{@subscription.user.name} will be suspended for #{suspension.duration} days starting on #{suspension.start_date.strftime(STANDARD_DATE_FORMAT)}"
            else
              flash[:error] = "Suspension could not be scheduled."
            end
          end

          begin
            redirect_to :back
          rescue ActionController::RedirectBackError
            redirect_to admin_subscriptions_url
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

    def find_subscriber
      @subscriber = User.find(params[:subscriber_id])
    end

    def load_publications_and_states
      @publications = Publication.all
      @states = %w(active squatter trial)
    end
end

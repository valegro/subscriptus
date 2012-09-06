class Admin::ScheduledSuspensionsController < AdminController
  layout 'admin/subscriptions'
  def index
    @scheduled_suspensions = ScheduledSuspension.queued
  end

  def destroy
    @ss = ScheduledSuspension.queued.find(params[:id])
    subscription = @ss.subscription
    if @ss.destroy!
      flash[:notice] = "Scheduled suspension to #{subscription.publication.name} for #{subscription.user.name} has been cancelled."
    end
    
    redirect_to admin_scheduled_suspensions_url
  end

end

class S::ProfileController < SController
  include S::SubscriptionsHelper

  def index
	@profile = current_user.id
  end
  def update

    @profile = User.find(current_user.id)
    if @profile.update_attribute(:email,params[:user][:email])
		@profile.sync_to_wordpress(current_user.password)
		@profile.sync_to_campaign_master
		flash[:notice] = "Email Updated"
		redirect_to :action => :edit
    else 
		flash[:notice] = "Email update failed"
		redirect_to :action => :edit
    end
  end
  def show 
	@user = User.find(current_user.id)
  end
end

class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  before_filter :load_publication
  
  layout "login_page"

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      if current_user.next_login_redirect
        redirect_to current_user.next_login_redirect
        current_user.update_attributes(:next_login_redirect => nil)
      else
        redirect_back_or_default(current_user.admin? ? admin_subscriptions_path : s_subscriptions_path)
      end
    else
      flash.now[:notice] = "Login Failed!"
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default login_url
  end
  
  private
  
  def load_publication
    @publication = Publication.for_domain(current_domain).first
  end
end

class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  layout :login_page

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_to current_user.admin? ? admin_subscriptions_path : s_subscriptions_path
    else
      flash[:notice] = "Login Failed!"
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default login_url
  end
end

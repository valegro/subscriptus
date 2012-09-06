class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update] 
  skip_before_filter :require_user
  layout "login_page"

  def new
  end

  def create
    @user = User.find_by_email(params[:email])  
    if @user
      @user.transaction do
        @user.next_login_redirect = session[:return_to]
        @user.deliver_password_reset_instructions!
      end
      flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."  
      redirect_to login_url
    else  
      flash[:notice] = "No user was found with that email address"  
      render :action => :new  
    end  
  end

  def edit
    
  end

  def update  
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.password == @user.password_confirmation
      # Cannot use validations here as some old data from Crikey is invalid
      @user.save_with_validation(false)
      @user.sync_to_wordpress(@user.password)
      flash[:notice] = "Password successfully updated."  
      redirect_to root_url
    else
      flash[:notice] = "The password you provided does not match the confirmation"
      render :action => :edit  
    end
  end

  private
    def load_user_using_perishable_token  
      @user = User.find_using_perishable_token(params[:id])  
      unless @user  
        flash[:notice] = "We're sorry, but we could not locate your account. " +  
          "If you are having issues try copying and pasting the URL " +  
          "from your email into your browser or restarting the " +  
          "reset password process."  
        redirect_to root_url  
      end  
    end 
end

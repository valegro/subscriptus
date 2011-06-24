# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user, :sort_order
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :require_ssl

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :card_number

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_url
      return false
    end
  end

  def require_admin
    unless current_user && current_user.admin?
      flash[:error] = "Permission Denied"
      redirect_to login_url
    end
  end
  
  def csv_response_headers(filename=nil)
    response.headers['Content-type'] = 'text/csv' 
    response.headers['Content-disposition'] = "attachment"
  end
 
  protected
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def sort_order(default)
      "#{(params[:c] || default.to_s).gsub(/[\s;'\"]/,'')} #{params[:d] == 'down' ? 'DESC' : 'ASC'}"
    end

    def require_ssl
      redirect_to :protocol => "https://" unless (request.ssl? or local_request?)  
    end
end

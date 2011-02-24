class AdminController < ApplicationController
  layout "admin"
  before_filter :require_user
  before_filter :require_admin

  def index
    redirect_to admin_subscriptions_path
  end
  
  def sort_by_conditions
    conditions = {}
    if params.has_key?(:c) && params.has_key?(:d)
      conditions[:order] = case params[:d]
        when 'up' then "#{params[:c]} ASC"
        when 'down' then "#{params[:c]} DESC"
      end
    end
    conditions
  end
end

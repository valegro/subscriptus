class AdminController < ApplicationController
  layout "admin"
  before_filter :require_user
  before_filter :require_admin

  def index
    redirect_to admin_subscriptions_path
  end
end

class Admin::SystemController < AdminController
  layout "admin/system"

  def index
    redirect_to admin_system_users_path
  end
end

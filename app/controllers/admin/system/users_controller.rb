class Admin::System::UsersController < Admin::SystemController
  def index
    @admins = User.admins.paginate(:page => params[:page] || 1)
  end
end

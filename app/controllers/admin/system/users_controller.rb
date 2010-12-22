class Admin::System::UsersController < Admin::SystemController
  def index
    @admins = User.admins.paginate(:page => params[:page] || 1)
  end

  def new
    @user = User.new(:admin => true)
  end

  def create
    @user = User.new(params[:user])
    @user.admin = true
    @user.role = 'admin'
    if @user.save
      flash[:notice] = "Created Admin"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    if @user.save
      flash[:notice] = "Updated Admin: #{h(@user.name)}"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
end

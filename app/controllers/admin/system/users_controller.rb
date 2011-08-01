class Admin::System::UsersController < Admin::SystemController
  before_filter :find_user, :only => [:edit, :update, :destroy]
  
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
    User.validate_as(:admin) do
      if @user.save
        flash[:notice] = "Created Admin '#{h(@user.name)}'."
        redirect_to :action => :index
      else
        render :action => :new
      end
    end
  end

  def edit

  end

  def update
    @user.attributes = params[:user]
    if @user.save
      flash[:notice] = "Updated Admin: #{h(@user.name)}"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @user.destroy
      flash[:notice] = "Admin '#{h(@user.name)}' has been deleted."
    end
    redirect_to :action => :index
  end
  
private
  def find_user
    @user = User.find(params[:id])
  end
end

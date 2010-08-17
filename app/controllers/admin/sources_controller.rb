class Admin::SourcesController < AdminController
  before_filter :find_source, :only => [ :edit, :update, :destroy ]

  def index
    @sources = Source.all
  end

  def new
    @source = Source.new
  end

  def create
    @source = Source.new(params[:source])
    if @source.save
      flash[:notice] = "Created Source"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def update
    @source.attributes = params[:source]
    if @source.save
      flash[:notice] = "Updated Source: #{h(@source.code)}"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def destroy
    @source.destroy
    flash[:notice] = "Deleted Source"
    redirect_to :action => :index
  end

  private
    def find_source
      @source = Source.find(params[:id])
    end
end

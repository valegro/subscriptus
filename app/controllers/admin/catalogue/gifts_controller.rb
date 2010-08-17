class Admin::Catalogue::GiftsController < Admin::CatalogueController
  before_filter :find_gift, :only => [ :destroy, :edit, :show, :update ]

  def index
    @gifts = Gift.paginate(:page => params[:page] || 1)
  end

  def new
    @gift = Gift.new
  end

  def show
  end

  def create
    @gift = Gift.new(params[:gift])
    if @gift.save
      flash[:notice] = "Created Gift"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def update
    @gift.attributes = params[:gift]
    if @gift.save
      flash[:notice] = "Updated Gift: #{h(@gift.name)}"
      redirect_to :action => :show
    else
      render :action => :edit
    end
  end

  def destroy
    @gift.destroy
    flash[:notice] = "Deleted Gift"
    redirect_to :action => :index
  end

  private
    def find_gift
      @gift = Gift.find(params[:id])
    end
end

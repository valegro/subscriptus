class Admin::Catalogue::PublicationsController < Admin::CatalogueController
  before_filter :find_publication, :only => [ :destroy, :edit, :show, :update ]

  def index
    @publications = Publication.paginate(:page => params[:page] || 1, :order => sort_order('name'))
  end

  def new
    @publication = Publication.new
  end

  def show
    @request_host = request.host
    @subscriptions = @publication.subscriptions.recent.paginate(:page => params[:page] || 1)
  end

  def create
    @publication = Publication.new(params[:publication])
    if @publication.save
      flash[:notice] = "Created Publication"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def update
    @publication.attributes = params[:publication]
    if @publication.save
      flash[:notice] = "Updated Publication: #{h(@publication.name)}"
      redirect_to :action => :show
    else
      render :action => :edit
    end
  end

  def destroy
    @publication.delete
    flash[:notice] = "Deleted Publication"
    redirect_to :action => :index
  end

  private
    def find_publication
      @publication = Publication.find(params[:id])
    end

end

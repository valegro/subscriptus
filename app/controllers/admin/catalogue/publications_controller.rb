class Admin::Catalogue::PublicationsController < Admin::CatalogueController
  before_filter :find_publication, :only => [ :destroy, :edit, :show, :update ]
  before_filter :load_offers, :only => [ :edit, :update ]

  def index
    @publications = Publication.paginate(:page => params[:page] || 1, :order => sort_order('name'))
  end

  def new
    @publication = Publication.new
    @offers = @publication.offers
  end

  def show
    @request_host = request.host
    @subscriptions = @publication.subscriptions.recent.paginate(:page => params[:page] || 1)
  end

  def create
    @publication = Publication.new(params[:publication])
    @offers = @publication.offers
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

    def load_offers
      @offers = @publication.offers
    end

end

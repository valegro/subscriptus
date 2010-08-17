class Admin::Catalogue::OffersController < Admin::CatalogueController
  before_filter :load_publications, :except => [ :index, :destroy ]
  before_filter :find_offer, :except => [ :new, :index, :create ]

  def index
    @offers = Offer.all
  end

  def new
    @offer = Offer.new
    @offer.offer_terms.build
  end

  def create
    @offer = Offer.new(params[:offer])
    if @offer.save
      flash[:notice] = "Created Offer"
      redirect_to admin_catalogue_offer_path(@offer)
    else
      render :action => :new
    end
  end

  def show
    @gifts = Gift.in_stock
    @offer_term = @offer.offer_terms.new
    @sources = Source.all.map { |s| [ s.code, s.id ] }
  end

  def add_gift
    @gift = Gift.find(params[:gift_id])
    render :update do |page|
      if @offer.gifts.include?(@gift)
        page.alert("That gift is already part of the offer")
      else
        @offer.gifts.add(@gift, params[:optional])
        page.replace_html "offered_gifts", :partial => "gifts", :object => @offer.gifts
        page['gifts_dialog'].dialog('close');
      end
    end
  end

  def remove_gift
    @gift = Gift.find(params[:gift_id])
    @offer.gifts.delete(@gift)
    render :update do |page|
      page.replace_html "offered_gifts", :partial => "gifts", :object => @offer.gifts
    end
  end

  def destroy
    @offer.destroy
    flash[:notice] = "Deleted Offer"
    redirect_to :action => :index
  end

  private
    def load_publications
      @publications = Publication.all
    end

    def find_offer
      @offer = Offer.find(params[:id])
    end
end

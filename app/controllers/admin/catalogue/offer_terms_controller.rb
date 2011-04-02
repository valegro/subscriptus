class Admin::Catalogue::OfferTermsController < Admin::CatalogueController
  before_filter :load_offer

  def create
    @offer_term = @offer.offer_terms.build(params[:offer_term])
    render :update do |page|
      if @offer_term.save
        page.replace_html "offer_terms", :partial => "all_terms", :object => @offer.offer_terms
        page['term_option_dialog'].dialog('close');
      else
        page.alert(@offer_term.errors.full_messages.join("\n"))
      end
    end
  end

  def destroy
    @offer_term = @offer.offer_terms.find(params[:id])
    @offer_term.destroy
    render :update do |page|
      page.replace_html "offer_terms", :partial => "all_terms", :object => @offer.offer_terms(true)
    end
  end

  private
    def load_offer
      @offer = Offer.find(params[:offer_id])
    end
end

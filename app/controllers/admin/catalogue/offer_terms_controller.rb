class Admin::Catalogue::OfferTermsController < Admin::CatalogueController
  def create
    @offer = Offer.find(params[:offer_id])
    @offer_term = @offer.offer_terms.build(params[:offer_term])
    render :update do |page|
      if @offer_term.save
        page.replace_html "offer_terms", :partial => "offer_term", :collection => @offer.offer_terms
        page['term_option_dialog'].dialog('close');
      else
        page.alert(@offer_term.errors.full_messages.join("\n"))
      end
    end
  end
end

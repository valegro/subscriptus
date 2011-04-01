class Admin::CatalogueController < AdminController
  layout "admin/catalogue"

  def index
    redirect_to admin_catalogue_offers_path
  end
end

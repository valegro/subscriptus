class Admin::CatalogueController < AdminController
  layout "admin/catalogue"

  def index
    redirect_to admin_catalogue_publications_path
  end
end

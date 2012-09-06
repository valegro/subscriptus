class SController < ApplicationController
  layout "subscriber"
  before_filter :require_user

  def index
    redirect_to s_subscriptions_path
  end

end

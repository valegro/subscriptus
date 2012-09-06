class S::SubscriptionsController < SController
  include S::SubscriptionsHelper
  
  def index
    @subscriptions = current_user.subscriptions
  end
end

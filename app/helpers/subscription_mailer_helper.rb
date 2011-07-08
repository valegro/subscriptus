module SubscriptionMailerHelper
  include ActionController::UrlWriter
  def extract_liquid_variables(subscription, more_variables={})
    { :subscription => subscription,
      :user => subscription.user,
      :publication_name => subscription.publication.name,
      :expiration_date => subscription.try(:expires_at).try(:strftime, "%d/%m/%Y"),
      :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id)
    }.merge(more_variables)
  end
end

module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/ then '/'
    # Gifts
    when /admin catalogue gifts new/ then new_admin_catalogue_gift_path
    when /admin catalogue gift page for (.*)/ then admin_catalogue_gift_path($1)
    when /admin catalogue gift edit page for (.*)/ then edit_admin_catalogue_gift_path($1)
    # Publications
    when /admin catalogue publications new/ then new_admin_catalogue_publication_path
    when /admin catalogue publication page for (.*)/ then admin_catalogue_publication_path($1)
    when /admin catalogue publication edit page for (.*)/ then edit_admin_catalogue_publication_path($1)
    # Sources
    when /admin sources new/ then new_admin_source_path
    when /admin sources page for (.*)/ then admin_source_path($1)
    when /admin sources edit page for (.*)/ then edit_admin_source_path($1)
    # Offers
    when /admin catalogue offers new/ then new_admin_catalogue_offer_path
    when /admin catalogue offer page for (.*)/ then admin_catalogue_offer_path($1)
    when /admin catalogue offer edit page for (.*)/ then edit_admin_catalogue_offer_path($1)
    when "admin subscription search page" then search_admin_subscriptions_path
    # Subscriptions
    when /admin subscriptions/ then admin_subscriptions_path
    when /admin cancelled subscriptions/ then cancelled_admin_subscriptions_path
    when /admin pending subscriptions/ then pending_admin_subscriptions_path
    # Sessions
    when /login/ then login_path
    # Subscribers
    when /s subscription payment page for (.*)/ then payment_s_subscription_path($1)
    when /s subscription direct debit page for (.*)/ then direct_debit_s_subscription_path($1)
    when /s subscriptions/ then s_subscriptions_path


    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)

ActionController::Routing::Routes.draw do |map|

  # Authlogic
  map.resource :user_session
  map.resources :password_resets
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  # Admin
  map.namespace :admin do |admin|
    admin.resources :subscriptions, :collection => {
      :search => [ :get, :post ],
      :active => :get,
      :trial => :get,
      :squatters => :get,
      :pending => :get,
      :payment_failed => :get,
      :payment_due => :get,
      :recent => :get,
      :ended => :get
    }, :member => {
      :expire => :get,
      :activate => :get,
      :cancel => :get,
      :verify => [ :get, :post, :put ],
      :suspend => [ :get, :post ],
      :set_expiry => [ :get, :post ],
      :unsuspend => [ :post ],
      :unsubscribe => :get
    }
    admin.resources :orders, :member => { :fulfill => [:get, :post], :postpone => [:get, :post] }, :collection => { :delayed => :get, :completed => :get }
    admin.resources :subscribers, :member => { :sync => :get }
    admin.namespace :catalogue do |catalogue|
      catalogue.resources :offers, :member => { :add_gift => :post, :remove_gift => :post, :make_primary => :get }, :has_many => [ :offer_terms ]
      catalogue.resources :gifts
      catalogue.resources :publications
    end
    admin.resources :sources
    admin.resources :payments
    admin.resources :reports
    admin.namespace :system do |system|
      system.resources :users
    end
  end

  # Subscriber
  map.namespace :s do |subscriptions|
    subscriptions.resources :subscriptions, :member => { :payment => :get, :pay => :post, :direct_debit => :get, :cancel => :get }, :collection => { :download_pdf => :get }
  end

  # Signup
  map.with_options  :controller => 'subscribe' do |s|
    s.new_renew      '/renew',       :action => "edit",    :conditions => { :method => :get }
    s.renew          '/renew',       :action => "update",  :conditions => { :method => :put }
    s.new_subscribe  '/subscribe',   :action => "new",     :conditions => { :method => :get }
    s.subscribe      '/subscribe',   :action => "create",  :conditions => { :method => :post }
    s.connect        '/subscribe',   :action => "create",  :conditions => { :method => :put }
    s.thanks         '/thanks',      :action => "thanks"
    s.complete       '/complete',    :action => "complete"
  end

  # Unsubscribe
  map.resource :unsubscribe, :controller => 'unsubscribe'

  # Webhooks
  map.namespace :webhooks do |webhooks|
    webhooks.resource :unbounce
  end
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

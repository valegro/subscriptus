ActionController::Routing::Routes.draw do |map|

  # Authlogic
  map.resource :user_session
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
      :verify => [ :get, :post ],
      :suspend => [ :get, :post ],
      :unsuspend => [ :post ]
    }
    admin.resources :orders, :member => { :fulfill => :get, :delay => :get }, :collection => { :delayed => :get, :completed => :get }
    admin.resources :subscribers
    admin.namespace :catalogue do |catalogue|
      catalogue.resources :offers, :member => { :add_gift => :post, :remove_gift => :post }, :has_many => [ :offer_terms ]
      catalogue.resources :gifts
      catalogue.resources :publications
    end
    admin.resources :sources
    admin.resources :payments
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
    s.resource :subscribe, :collection => { :thanks => :get }
    #s.subscribe "subscribe", :action => 'new', :method => :get
=begin
    s.subscribe_offer         'subscribe/offer', :action => 'offer', :method => :get
    s.subscribe_offer_next    'subscribe/offer', :action => 'offer', :method => :post, :commit=>'Next'

    s.subscribe_details         'subscribe/details', :action => 'details', :method => :get
    s.subscribe_details_next    'subscribe/details', :action => 'details', :method => :post, :commit=>'Next'

    s.subscribe_payment         'subscribe/payment', :action => 'payment', :method => :get
    s.subscribe_payment_next    'subscribe/payment', :action => 'payment', :method => :post, :commit=>'Finish'
    s.subscribe_payment_direct_debit  'subscribe/direct_debit', :action => 'direct_debit', :method => :get

    s.subscribe_result  'subscribe/result', :action => 'result', :method => :get
=end
  end

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
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

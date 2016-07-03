require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  get '/:market/flights/results' => 'flights#live_prices'
  get '/:lang/hotels/results' => 'flights#live_prices_hotels'
  # post '/live_prices_hotels' => 'flights#live_prices_hotels'
  get '/refresh' => 'flights#refresh'
  get '/refresh_hotels' => 'flights#refresh_hotels'
  get '/countries' => 'welcome#getCountries'
  get '/countries_hotel' => 'welcome#getCountriesHotel'
  get '/cities' => 'flights#cities'
  get '/nigeria' => 'flights#nigeria'
  get '/europe' => 'flights#europe'
  get '/africa' => 'flights#africa'
  get '/asia' => 'flights#asia'
  get '/usa' => 'flights#usa'
  get '/unsubscribe' => 'welcome#unsubscribe'
  post '/watchdog' => 'flights#watchdog'
  get '/:city/:iata' => 'flights#grid'
  get '/hotels' => 'welcome#index'
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

Rails.application.routes.draw do

  get '/recipes' => 'dishes#index'
  get '/dishes' => 'dishes#index'
  get '/discover' => 'dishes#index'

  get 'dish/create' => 'dishes#create'
  get 'dish/:id' => 'dishes#show'
  get 'dish/:id/:slug' => 'dishes#show'
  get 'dish/:id/edit' => 'dishes#edit'
  get 'dish/:id/:slug/edit' => 'dishes#edit'

  get 'recipe/:id' => 'dishes#show'
  get 'recipe/:id/:slug' => 'dishes#show'

  get '/sign_up' => 'account#sign_up'

  get '/members' => 'users#index'

  get 'member/:id' => 'users#show'
  get 'member/:id/:slug' => 'users#show'
  get 'member/:id/:slug/followers' => 'users#followers'
  get 'member/:id/:slug/following' => 'users#following'

  get '/activity' => 'app_events#activity'

  get '/sign_in' => 'account#sign_in'
  get '/logout' => 'account#logout'
  get '/forgot' => 'account#forgot_password'

  get 'account' => 'account#edit'
 
  get '/modal/sign_up' => 'account#sign_up_modal'
  get '/modal/sign_in' => 'account#sign_in_modal'
  get '/modal/forgot_password' => 'account#forgot_password_modal'
  get '/modal/share_your_dish' => 'dishes#share_your_dish_modal'

  get '/admin' => 'admin#view'

  namespace :api do
    post 'account' => 'account#save'
    post '/account/register' => 'account#register'
    post '/account/login' => 'account#login'
    post '/account/update_flags' => 'account#update_flags'
    post '/account/reset_password' => 'account#reset_password'

    api_resources :dishes do
      post '/dish/favorite' => 'dishes#favorite'
      post '/dishes/import_from_url' => 'dishes#import_from_url'
    end
    api_resources :user_reactions do
      post '/user_reactions/react' => 'user_reactions#react'
    end
    api_resources :followings
    api_resources :comments
    api_resources :users

  end

  root 'dishes#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

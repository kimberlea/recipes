Rails.application.routes.draw do

  get '/recipes' => 'recipes#index'
  get '/dishes' => 'recipes#index'
  get '/discover' => 'recipes#index'

  get 'dish/create' => 'recipes#create'
  get 'dish/:id' => 'recipes#show'
  get 'dish/:id/:slug' => 'recipes#show'
  get 'dish/:id/edit' => 'recipes#edit'
  get 'dish/:id/:slug/edit' => 'recipes#edit'

  get 'recipe/:id' => 'recipes#show'
  get 'recipe/:id/:slug' => 'recipes#show'

  get '/sign_up' => 'account#sign_up'
  post '/register' => 'account#register'

  get '/members' => 'users#index'

  get 'member/:id' => 'users#show'
  get 'member/:id/followers' => 'users#followers'
  get 'member/:id/following' => 'users#following'

  get '/activity' => 'app_events#activity'

  get '/sign_in' => 'account#sign_in'
  post '/login' => 'account#login'
  get '/logout' => 'account#logout'
  get '/forgot' => 'account#forgot_password'

  get 'account' => 'account#profile'
  post '/account' => 'account#save'
  post '/account/update_flags' => 'account#update_flags'
  post '/account/reset_password' => 'account#reset_password'
 
  post '/following' => 'followings#save'
  delete '/following' => 'followings#delete'

  post '/recipe' => 'recipes#save'
  post '/dish' => 'recipes#save'
  delete '/recipe' => 'recipes#delete'
  delete '/dish' => 'recipes#delete'
  post '/recipe/favorite' => 'recipes#favorite'
  post '/dish/favorite' => 'recipes#favorite'

  post '/user_reaction' => 'user_reactions#save'
  delete '/user_reaction' => 'user_reactions#delete'

  post '/comment' => 'comments#save'

  get '/modal/sign_up' => 'account#sign_up_modal'
  get '/modal/sign_in' => 'account#sign_in_modal'
  get '/modal/share_your_recipe' => 'recipes#share_your_recipe_modal'

  root 'recipes#index'

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

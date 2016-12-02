Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'

  scope '(:locale)', locale: /en|de|fr|ar/ do
    root 'static_pages#map'
    get '/:locale' => 'static_pages#map'
    get '/about' => 'static_pages#about'
    get '/chronicle' => 'static_pages#chronicle'
    get '/category/:category' => 'places#index', as: :category
    get '/login' => 'sessions#new'
    post '/login' => 'sessions#create'
    get '/logout' => 'sessions#destroy'

    get 'places/review_index' => 'review#review_index'
    get '/:id/review_place' => 'review#review_place', as: :review_place
    get '/:id/confirm_place' => 'review#confirm_place', as: :confirm_place
    get '/:id/refuse_place' => 'review#refuse_place', as: :refuse_place
    get '/:id/review_translation' => 'review#review_translation', as: :review_translation
    get '/:id/confirm_translation' => 'review#confirm_translation', as: :confirm_translation
    get '/:id/refuse_translation' => 'review#refuse_translation', as: :refuse_translation

    resources :places do
      resources :descriptions
    end
    resources :users
    resources :announcements


    scope protocol: 'https' do
      get '/contact' => 'messages#new'
      post '/contact' => 'messages#create'
    end
  end
end

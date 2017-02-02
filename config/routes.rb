require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  get '', to: 'static_pages#index'

  scope '(:locale)', locale: /en|de|fr|ar/ do
    root 'static_pages#map'
    get '/:locale' , to: 'static_pages#map'

    # Static pages
    get '/about' , to: 'static_pages#about'
    get '/map' , to: 'static_pages#map'
    get '/category/:category' , to: 'places#index', as: :category
    get '/contact' , to: 'messages#new'
    post '/contact' , to: 'messages#create'


    # Reviewing
    get 'places/review_index' , to: 'review#review_index'

    scope '/places/:id' do
      get '/review' , to: 'places_review#review', as: :review_place
      get '/confirm' , to: 'places_review#confirm', as: :confirm_place
      get '/refuse' , to: 'places_review#refuse', as: :refuse_place

      scope '/translation' do
        get '/review' , to: 'translations_review#review', as: :review_translation
        get '/confirm' , to: 'translations_review#confirm', as: :confirm_translation
        get '/refuse' , to: 'translations_review#refuse', as: :refuse_translation
      end

    end

    # Place ressources
    resources :places do
      resources :descriptions
    end

    resources :users
    get '/login' , to: 'sessions#new'
    post '/login' , to: 'sessions#create'
    get '/logout' , to: 'sessions#destroy'

    resources :announcements
    get '/chronicle' , to: 'static_pages#chronicle'
  end
end

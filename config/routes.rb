require 'sidekiq/web'
require 'routing/access_constraints'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  get '', to: 'static_pages#choose_locale'

  scope '(:locale)', locale: /en|de|fr|ar/ do
    root 'static_pages#choose_locale'
    get '/start', to: 'static_pages#landing_page', as: :landing_page

    # Password reset
    get '/request_password_reset/new', to: 'password_reset#request_password_reset', as: :request_password_reset
    post '/request_password_reset', to: 'password_reset#create_password_reset'
    get '/reset_password/:id/:token', to: 'password_reset#reset_password', as: :reset_password
    patch '/reset_password', to: 'password_reset#set_new_password'

    scope '/map' do
      # TODO remove constraint and add require_login before action in maps controller
      get '/index', to: 'maps#index', as: :maps
      post '', to: 'maps#create'
      get '/new', to: 'maps#new', as: :new_map

      scope '/:map_token', constraints: MapAccessRestriction.new do
        get '/show' , to: 'maps#show', as: :map
        get '/edit', to: 'maps#edit', constraints: MapOwnershipRestriction.new, as: :edit_map
        patch '', to: 'maps#update', constraints: MapOwnershipRestriction.new
        delete '', to: 'maps#destroy', constraints: MapOwnershipRestriction.new, as: :destroy_map

        # map static pages
        get '/about' , to: 'maps#about'
        get '/contact' , to: 'messages#new'
        post '/contact' , to: 'messages#create'

        # Map / place ressources
        get '/places', to: 'places#index'

        resources :places, except: [:index, :show], constraints: PlacesAccessRestriction.new do
          resources :descriptions
        end

        # Reviewing, access restriction handled by place ressource access restriction
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

        resources :announcements
        get '/chronicle' , to: 'maps#chronicle'
      end
    end

    # User accessible user resources
    resources :users, only: [:show, :edit, :update]
    get '/login' , to: 'sessions#new'
    post '/login' , to: 'sessions#create'
    get '/logout' , to: 'sessions#destroy'
    post '/landing_page' , to: 'sessions#create_with_login', as: :create_with_login

    namespace :admin, constraints: AdminConstraint.new do
      get '', to: 'dashboard#index', as: :dashboard
      get '/settings', to: 'settings#edit'
      patch '/settings', to: 'settings#update'

      resources :users
    end
  end
end

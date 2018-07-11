require 'sidekiq/web'
require 'routing/access_constraints'

Rails.application.routes.draw do
  default_url_options protocol: :https if Rails.env == 'production'

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

    get '/index', to: 'maps#index', as: :maps
    post '', to: 'maps#create'
    get '/new', to: 'maps#new', as: :new_map
    get '/needs_unlock', to: 'maps#needs_unlock'

    # Map invitation
    post '/share_map/:id', to: 'maps#send_invitations', as: :send_invitations

    # Embedded stuff
    scope '/:map_token', constraints: MapAccessRestriction.new do
      get '' , to: 'maps#show', as: :map
      get '/serve_pois' , to: 'maps#serve_pois'
      get '/embedded', to: 'maps#show', as: :map_embedded
      get '/edit', to: 'maps#edit', as: :edit_map
      patch '', to: 'maps#update'
      delete '', to: 'maps#destroy', as: :destroy_map
      get '/unlock', to: 'maps#unlock'

      # map static pages
      get '/about' , to: 'maps#about'
      get '/contact' , to: 'messages#new'
      post '/contact' , to: 'messages#create'

      # map categories
      scope '/categories', constraints: CategoriesAccessRestriction.new do
        patch '/:id', to: 'categories#update'
        delete '/:id', to: 'categories#destroy'
        post '/', to: 'categories#create'
        get '/', to: 'categories#index'
      end

      # Map / place ressources
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

    # User resources
    resources :users, except: [:destroy, :index, :show, :new]
    get '/sign_up', to: 'users#sign_up', as: :sign_up
    get '/login' , to: 'sessions#new'
    post '/login' , to: 'sessions#create'
    get '/logout' , to: 'sessions#destroy'
    post '/landing_page' , to: 'sessions#create_with_login', as: :create_with_login

    # Admin stuff
    namespace :admin, constraints: AdminConstraint.new do
      get '', to: 'dashboard#index', as: :dashboard
      get '/settings', to: 'settings#edit'
      get '/settings/captcha_system_status', to: 'settings#captcha_system_status'
      patch '/settings', to: 'settings#update'

      get 'users', to: 'users#index', as: :index_users
      delete 'users/:id', to: 'users#destroy', as: :delete_user
    end
  end
end

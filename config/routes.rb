require 'sidekiq/web'

class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find(request.session[:user_id])
    user && user.is_admin?
  end
end

class MapAccessRestriction
  attr_reader :token

  def is_secret_link?
    Map.find_by(secret_token: token)
  end

  def can_access_as_guest?
    map = Map.find_by(public_token: token)
    map && map.is_public
  end

  def matches?(request)
    @token = request[:map_token]
    return true if is_secret_link? || can_access_as_guest?
    false
  end
end

class PlacesAccessRestriction
  attr_reader :token

  def is_secret_link?
    Map.find_by(secret_token: token)
  end

  def can_commit_as_guest?
    map = Map.find_by(public_token: token)
    map && map.is_public && map.allow_guest_commits
  end

  def matches?(request)
    @token = request[:map_token]
    return true if is_secret_link? || can_commit_as_guest?
    false
  end
end

class LoginStatusRestriction
  def matches?(request)
    return false unless request.session[:user_id]
    User.find(request.session[:user_id])
  end
end

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  get '', to: 'static_pages#choose_locale'

  scope '(:locale)', locale: /en|de|fr|ar/ do
    root 'static_pages#choose_locale'

    # Password reset
    get '/request_password_reset/new', to: 'password_reset#request_password_reset', as: :request_password_reset
    post '/request_password_reset', to: 'password_reset#create_password_reset'
    get '/reset_password/:id/:token', to: 'password_reset#reset_password', as: :reset_password
    patch '/reset_password', to: 'password_reset#set_new_password'

    scope '/map' do
      get '/new', to: 'maps#new', as: :new_map
      post '/', to: 'maps#create'

      scope '/:map_token', constraints: MapAccessRestriction.new do
        get '/show' , to: 'maps#show', as: :map
        get '/edit', to: 'maps#edit', as: :edit_map
        patch '', to: 'maps#update'

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

    namespace :admin, constraints: AdminConstraint.new do
      get '', to: 'dashboard#index', as: :dashboard
      get '/settings', to: 'settings#edit'
      patch '/settings', to: 'settings#update'

      resources :users
    end
  end
end

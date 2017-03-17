require 'sidekiq/web'

class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find(request.session[:user_id])
    user && user.is_admin?
  end
end

class PlaceAccessRestriction
  def can_commit?
    @settings['allow_guest_commits'] || @user.signed_in?
  end

  def matches?(request)
    @settings = Admin::Setting.all_settings
    @user = User.find_by(id: request.session[:user_id]) || GuestUser.new
    can_commit?
  end
end

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

    # Password reset
    get '/request_password_reset/new', to: 'password_reset#request_password_reset', as: :request_password_reset
    post '/request_password_reset', to: 'password_reset#create_password_reset'
    get '/reset_password/:id/:token', to: 'password_reset#reset_password', as: :reset_password
    patch '/reset_password', to: 'password_reset#set_new_password'

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
    resources :places, except: [:index], constraints: PlaceAccessRestriction.new do
      resources :descriptions
    end
    # get '/places/new', to: 'places#new', constraints: PlaceAccessRestriction.new
    # post '/places', to: 'places#create', constraints: PlaceAccessRestriction.new

    get '/places', to: 'places#index'

    # User accessible user resources
    resources :users, only: [:show, :edit, :update]
    get '/login' , to: 'sessions#new'
    post '/login' , to: 'sessions#create'
    get '/logout' , to: 'sessions#destroy'

    namespace :admin do
      get '', to: 'dashboard#index', as: :dashboard
      get '/settings', to: 'settings#edit'
      patch '/settings', to: 'settings#update'

      resources :users
    end
 
    resources :announcements
    get '/chronicle' , to: 'static_pages#chronicle'
  end
end

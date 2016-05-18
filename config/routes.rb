Rails.application.routes.draw do
  scope '(:locale)', locale: /en|de|fr|ar/ do
    root 'static_pages#map'
    get '/:locale' => 'static_pages#map'
    get '/about' => 'static_pages#about'
    get '/category/:category' => 'places#index', as: :category
    resources :places do
      resources :descriptions
    end
  end
end

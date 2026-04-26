Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :doctors, only: [] do
        resources :patients, only: [:index, :create], module: :doctors
        resources :available_patients, only: [:index], module: :doctors
      end
    end
  end
end

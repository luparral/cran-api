Rails.application.routes.draw do
  resources :packages, only: :index
end

Rails.application.routes.draw do
  get 'statistics/show'
  post 'statistics/refresh'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

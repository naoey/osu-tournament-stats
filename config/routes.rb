Rails.application.routes.draw do
  get 'statistics/show'
  get 'statistics/match/:id', to: 'statistics#show_match'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

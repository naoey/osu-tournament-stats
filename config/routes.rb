Rails.application.routes.draw do
  root to: redirect('/statistics/matches')

  get 'tournaments', to: 'tournaments#show'
  post 'tournaments', to: 'tournaments#add', format: :json
  delete 'tournaments/:id', to: 'tournaments#delete', format: :json
  put 'tournaments/:id', to: 'tournaments#edit', format: :json

  get 'statistics/matches', to: 'statistics#show_matches'
  get 'statistics/players', to: 'statistics#show_all_players'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

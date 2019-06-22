Rails.application.routes.draw do
  root to: redirect('/statistics/matches')

  get 'tournaments', to: 'tournaments#show'
  delete 'tournaments', to: 'tournaments#delete'
  put 'tournaments', to: 'tournaments#edit'

  get 'statistics/matches', to: 'statistics#show_matches'
  get 'statistics/players', to: 'statistics#show_all_players'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

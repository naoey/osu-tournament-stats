Rails.application.routes.draw do
  get 'statistics/matches', to: 'statistics#show_matches'
  get 'statistics/players', to: 'statistics#show_all_players'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

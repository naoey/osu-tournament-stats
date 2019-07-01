Rails.application.routes.draw do
  devise_for :players, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'secret',
    confirmation: 'verification',
    registration: 'register',
    edit: 'edit/profile'
  }
  root :to => redirect('/statistics/matches')

  get 'statistics/matches', to: 'statistics#show_matches'
  get 'statistics/players', to: 'statistics#show_all_players'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  get 'matches', to: 'matches#show'
  get 'matches/:id', to: 'matches#show_match'
  post 'matches/add', to: 'matche#add'
  delete 'matches/:id', to: 'matches#delete'
  put 'matches/:id', to: 'matches#edit'

  get 'tournaments', to: 'tournaments#show'
  get 'tournaments/:id', to: 'tournaments#show_tournament'
  post 'tournaments', to: 'tournaments#add'
  delete 'tournaments/:id', to: 'tournaments#delete'
  put 'tournaments/:id', to: 'tournaments#edit'

  get 'statistics/players', to: 'statistics#show_all_players'
  get 'statistics/tournaments/:id', to: 'statistics#show_tournament'
  get 'statistics/matches/:id', to: 'statistics#show_match'

  devise_for :players, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'secret',
    confirmation: 'verification',
    registration: 'register',
    edit: 'edit/profile',
  }
  root to: redirect('/tournaments')
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  get 'beatmaps/get'
  get 'matches', to: 'matches#show'
  get 'matches/:id', to: 'matches#show_match'
  post 'matches', to: 'matches#add'
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

  get 'beatmaps', to: 'beatmaps#search'
  get 'beatmaps/:id', to: 'beatmaps#show'

  get 'discord/servers', to: 'discord#show'
  get 'discord/servers/:id', to: 'discord#show_server'
  get 'discord/servers/:server_id/exp', to: 'discord#show_exp_leaderboard'
  put 'discord/servers/:id', to: 'discord#update'

  devise_for :players, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'secret',
    confirmation: 'verification',
    registration: 'register',
    edit: 'edit/profile',
  }, controllers: {
    omniauth_callbacks: 'auth'
  }

  devise_scope :player do
    get 'authorise/osu', to: 'auth#osu'
    get 'authorise/success', to: 'auth#success'
  end

  root to: redirect('/tournaments')
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

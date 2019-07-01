Rails.application.routes.draw do
  devise_for :players, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'secret',
    confirmation: 'verification',
    registration: 'register',
    edit: 'edit/profile',
  }
  root to: redirect('/tournaments')

  get 'tournaments', to: 'tournaments#show'
  get 'tournaments/:id', to: 'tournaments#show_tournament'
  post 'tournaments', to: 'tournaments#add', format: :json
  delete 'tournaments/:id', to: 'tournaments#delete', format: :json
  put 'tournaments/:id', to: 'tournaments#edit', format: :json
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

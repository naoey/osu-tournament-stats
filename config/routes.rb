Rails.application.routes.default_url_options[:host] = ENV.fetch("HOST_URL")

Rails.application.routes.draw do
  # get "users/:id", to: "users#show"
  get "users/:id/edit", to: "users#show_edit_profile"
  delete "users/:id/connection", to: "users#delete_identity"
  get "/users/register_discord", to: "users#show_link_osu_discord"
  put "/users/me/ui_config", to: "users#update_ui_config"

  get "beatmaps/get"
  get "matches", to: "matches#show"
  get "matches/:id", to: "matches#show_match"
  post "matches", to: "matches#add"
  delete "matches/:id", to: "matches#delete"
  put "matches/:id", to: "matches#edit"

  get "tournaments", to: "tournaments#show"
  get "tournaments/:id", to: "tournaments#show_tournament"
  post "tournaments", to: "tournaments#add"
  delete "tournaments/:id", to: "tournaments#delete"
  put "tournaments/:id", to: "tournaments#edit"

  get "statistics/players", to: "statistics#show_all_players"
  get "statistics/tournaments/:id", to: "statistics#show_tournament"
  get "statistics/matches/:id", to: "statistics#show_match"

  get "beatmaps", to: "beatmaps#search"
  get "beatmaps/:id", to: "beatmaps#show"

  get "discord", to: "discord#invite"
  get "discord/servers", to: "discord#show"
  get "discord/servers/:id", to: "discord#show_server"
  get "discord/servers/:server_id/exp", to: "discord#show_exp_leaderboard"
  put "discord/servers/:id", to: "discord#update"

  devise_for :players,
             path: "",
             path_names: {
               sign_in: "login",
               sign_out: "logout",
               edit: "profile/edit"
             },
             controllers: {
               omniauth_callbacks: "auth"
             }

  devise_scope :player do
    get "authorise/osu", to: "auth#osu"
    get "authorise/discord", to: "auth#discord"
    get "authorise/success", to: "auth#success"
  end

  root to: redirect("/tournaments")
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :players, only: [:index, :show]
  get "random" => "players#show_random"

  post "create_multiplayer_game" => "multiplayer#create_game"
  post "join_multiplayer_game" => "multiplayer#join_game"
  
  get "handle_guest_game_state" => "multiplayer#handle_guest_game_state"
  get "handle_host_game_state" => "multiplayer#handle_host_game_state"

  # Defines the root path route ("/")
  mount ActionCable.server => '/cable'
end

class Session < ApplicationRecord
    belongs_to :game
  # Specifying the association to Player with a custom foreign key
    belongs_to :current_player, class_name: 'Player', foreign_key: 'current_player_id', optional: true

end
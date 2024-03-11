class Session < ApplicationRecord
    belongs_to :game
  # Specifying the association to Player with a custom foreign key
    belongs_to :current_player, class_name: 'Player', foreign_key: 'current_player_id', optional: true

    def self.game_cleanup!(sessions)
        sessions.each do |session|
            session.update(current_player: nil)
            session.update(card_dealt: false)
            session.update(game_ready: false)
            session.update(refreshes: 0)
            session.update(current_score: 0)
            session.save
        end
    end

    def self.battle_cleanup!(sessions)
        sessions.each do |session|
            session.update(current_player: nil)
            session.update(card_dealt: false)
            session.save
        end
    end
end
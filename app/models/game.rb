class Game < ApplicationRecord
    has_many :session_games, dependent: :destroy
    has_many :sessions, through: :session_games, dependent: :destroy
    validates_length_of :sessions, maximum: 2
    before_create :generate_invite_code

    WINNING_SCORE = 10


def both_cards_dealt?
    session_games.all? { |sg| sg.current_player.present? }
end

def handle_current_round!
    return unless both_cards_dealt?

    first_session_game = session_games.first
    second_session_game = session_games.second

    winner_loser = begin 
        if first_session_game.current_player.war > second_session_game.current_player.war
            first_session_game.increment!(:current_score)
            [first_session_game, second_session_game]
        elsif first_session_game.current_player.war < second_session_game.current_player.war
            second_session_game.increment!(:current_score)
            [second_session_game, first_session_game]
        elsif first_session_game.current_player.war == second_session_game.current_player.war
            first_session_game.increment!(:current_score)
            second_session_game.increment!(:current_score)
            "tie"
        end
    end

    if winner_loser == "tie"
        ActionCable.server.broadcast("GameChannel", { id: id, action: "round_winner", winner: "tie", })
    else
        ActionCable.server.broadcast("GameChannel", { id: id, action: "round_winner", winner: winner_loser.first, loser: winner_loser.last})
    end

    if first_session_game.current_score == WINNING_SCORE || second_session_game.current_score == WINNING_SCORE
        game_winner = first_session_game.current_score == 10 ? sessions.first : sessions.second
        game_loser = first_session_game.current_score == 10 ? sessions.second : sessions.first

        game_winner.active_session_game.increment!(:wins)
        game_loser.active_session_game.increment!(:losses)

        ActionCable.server.broadcast("GameChannel", { id: id, action: "game_winner", winner: game_winner, loser: game_loser })
    end

    # cleanup
    sessions.each do |session|
        session.active_session_game.update(current_player: nil)
    end
end

def restart!
    transaction do
      sessions.each do |session|
        # Deactivate current session games and create new ones
        current_session_game = session.active_session_game
        current_session_game&.update!(active: false) if current_session_game

        SessionGame.create!(session: session, game: self, active: true)
      end
    end
    ActionCable.server.broadcast("GameChannel", { id: id, action: "game_restart" })

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to restart game: #{e.message}"
    # Consider re-raising the exception or handling it appropriately
    # to notify the caller of this method that the restart failed.
  end

  def self.broadcast_invalid_game(id)
    # could be an invalid id therefore channel a client is subscribed to
    ActionCable.server.broadcast("GameChannel", { action: "invalid_game", id: id })
  end

 def brodcast_invalid_game
    self.class.broadcast_invalid_game(id)
  end 


private

    def generate_invite_code
        loop do
            invite_code = SecureRandom.alphanumeric(5)
            p "invite_code: #{invite_code}"
            self.invite_code = invite_code
            
            break unless Game.exists?(invite_code: invite_code)
        end
    end
end
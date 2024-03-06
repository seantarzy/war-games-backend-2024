class Game < ApplicationRecord
    has_many :sessions, dependent: :destroy
    validates_length_of :sessions, maximum: 2
    before_create :generate_invite_code

    WINNING_SCORE = 10


def both_cards_dealt?
    sessions.all? { |session| !!session.card_dealt }
end

def handle_current_round
    winner_loser = begin 
        if sessions.first.current_player.war > sessions.second.current_player.war
            sessions.first.increment!(:current_score)
            [sessions.first, sessions.second]
        elsif sessions.first.current_player.war  < sessions.second.current_player.war
            sessions.second.increment!(:current_score)
            [sessions.second, sessions.first]
        elsif sessions.first.current_player.war  == sessions.second.current_player.war
            sessions.first.increment!(:current_score)
            sessions.second.increment!(:current_score)
            "tie"
        end
    end

    if winner_loser == "tie"
        ActionCable.server.broadcast("GameChannel", { id: id, action: "round_winner", winner: "tie", })
    else
        ActionCable.server.broadcast("GameChannel", { id: id, action: "round_winner", winner: winner_loser.first, loser: winner_loser.last})
    end

    if sessions.first.current_score == WINNING_SCORE || sessions.second.current_score == WINNING_SCORE
        game_winner = sessions.first.current_score == 10 ? sessions.first : sessions.second
        game_loser = sessions.first.current_score == 10 ? sessions.second : sessions.first

        game_winner.increment!(:wins)
        game_loser.increment!(:losses)

        ActionCable.server.broadcast("GameChannel", { id: id, action: "game_winner", winner: game_winner, loser: game_loser})
    end

    # cleanup
    sessions.each do |session|
        session.update(current_player: nil)
    end
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
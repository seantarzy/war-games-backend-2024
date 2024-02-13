class Game < ApplicationRecord
has_many :sessions
before_create :generate_invite_code

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
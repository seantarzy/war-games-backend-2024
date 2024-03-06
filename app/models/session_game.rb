class SessionGame < ApplicationRecord
    belongs_to :session
    belongs_to :game

    belongs_to :current_player, class_name: 'Player', foreign_key: 'current_player_id', optional: true
    after_create :activate
    
    REDRAWS_ALLOWED = 3


    def can_refresh?
        refreshes < REDRAWS_ALLOWED
    end

    private

    def activate
        self.active = true
        save!
    end

end
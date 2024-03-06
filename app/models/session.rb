class Session < ApplicationRecord
  has_many :session_games, dependent: :destroy
  has_one :active_session_game, -> { where(active: true) }, class_name: 'SessionGame'
  
  # Specifying the association to Player with a custom foreign key

  def activate_session_game(new_active_session_game)
    SessionGame.transaction do
      active_session_game&.update!(active: false) # Deactivate the current active session_game if any
      new_active_session_game.update!(active: true) # Activate the new one
    end
  rescue ActiveRecord::RecordInvalid => e
    # Handle the exception, maybe log it or notify someone
    Rails.logger.error "Failed to activate session game: #{e.message}"
  end

  def active_session_game
   @active_session_game ||= session_games.find_by(active: true)
  end

  def current_player
    active_session_game&.current_player
  end
end
class MultiplayerController < ApplicationController
    
    def create_game
        game = Game.create
        if game.valid?
          host_session = Session.create()
          host_session_game = SessionGame.create(session: host_session, game: game, active: true)
          render json: { game: game, session: host_session }, status: :created
        else
          render json: game.errors, status: :unprocessable_entity
        end
    end

    def join_game
        # create a new session

        # if theyre joining a game, the game should be findable by the game's invite code
        game = Game.find_by(invite_code: params[:invite_code])
    
        if game.valid? && game.sessions.count < 2
            guest_session = Session.create()
            guest_session_game = SessionGame.create(session: guest_session, game: game, active: true)
    

            return render json: { error: "failed to create session" }, status: :unprocessable_entity if guest_session.nil?

          render json: {game: game,session: guest_session }, status: :created
        else
          render json: game.errors, status: :unprocessable_entity
        end

      end
    
      def handle_guest_game_state
        game = Game.find_by(id: params[:game_id])
        
        return render json: { error: "Game not found" }, status: :not_found if game.nil?
        return render json: game.errors, status: :unprocessable_entity unless game.valid?
        
        case game.sessions.count
            when 1
            # If there's only one session, the host is waiting for a guest
            ActionCable.server.broadcast("GameChannel", { action: 'guest_joined_without_host', id: game.id })
            when 2
              # need to handle where the client thinks we;re game ready when we only have one session
            # If there are two sessions, the game is ready to start
            ActionCable.server.broadcast("GameChannel", { action: 'game_ready', id: game.id })
            else
            # If there are more than two sessions, something went wrong
            ActionCable.server.broadcast("GameChannel", { action: 'invalid_game', id: game.id })
            return render json: { error: "Too many sessions found" }, status: :unprocessable_entity
        end
    
        render json: { game: game }, status: :ok
      end
    
      def handle_host_game_state
        game = Game.find_by(id: params[:game_id])
        
        return render json: { error: "Game not found" }, status: :not_found if game.nil?
        return render json: game.errors, status: :unprocessable_entity unless game.valid?
    
        case game.sessions.count
            when 1
            # If there's only one session, the host is waiting for a guest
            ActionCable.server.broadcast("GameChannel", { action: 'game_initiated', id: game.id })
            when 2
            # If there are two sessions, the game is ready to start
            ActionCable.server.broadcast("GameChannel", { action: 'game_ready', id: game.id })
            else
            # If there are more than two sessions, something went wrong
            ActionCable.server.broadcast("GameChannel", { action: 'invalid_game', id: game.id })
            return render json: { error: "Too many sessions found" }, status: :unprocessable_entity
        end
    
        render json: { game: game }, status: :ok
      end


    def refresh_card
        
        game = Game.find(params[:game_id])
        validate_session_number_for_card_deal!(game)
        
        session = Session.find(params[:session_id])

        session_game = session.active_session_game

        if !session_game.can_refresh?
            return render json: { error: "Cannot refresh card" }, status: :unprocessable_entity
        end
        
        new_card = Player.draw_card
        session_game.update(current_player: new_card)
        session_game.increment!(:refreshes)
        render json: { card: new_card, session: session }, status: :ok
    end

    def draw_card
        game = Game.find(params[:game_id])
        validate_session_number_for_card_deal!(game)
        rando = Player.draw_card
        session = Session.find(params[:session_id])
        session_game = session.active_session_game
        session_game.update(current_player: rando)
      #  we only send the card to the current player, so don't need to broadcast
        render json: { card: rando, session: session }, status: :ok
    end

    def deal_card
        game = Game.find(params[:game_id])
        validate_session_number_for_card_deal!(game)
        session = Session.find(params[:session_id])
        session_game = session.active_session_game
        if session_game.current_player.blank?
          return render json: { error: "No current player. Player needs to draw a card before dealing it" }, status: :unprocessable_entity
        end

        player = Player.find(params[:player_id])
        if session_game.current_player != player
          return render json: { error: "Player card dealt does not match current player card drawn" }, status: :unprocessable_entity
        end
        
        ActionCable.server.broadcast(
            "GameChannel",
            {id: game.id, action: 'card_dealt', player: player, session: session}
        )

        if game.both_cards_dealt?
            game.handle_current_round
        end

        render json: { message: "Card dealt" }, status: :ok
    end

    private

    def validate_session_number_for_card_deal!(game)
      if game.sessions.count != 2
        # this is possible when both users join a game, but one of them leaves before the game ends (when the other user is dealing a card)
        # so we need to tell the user the game is invalid
          ActionCable.server.broadcast("GameChannel", { action: 'invalid_game', id: game.id })
          return render json: { error: "Invalid number of sessions" }, status: :unprocessable_entity
      end
    end
     
    
end
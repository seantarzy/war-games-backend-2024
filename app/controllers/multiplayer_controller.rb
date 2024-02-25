class MultiplayerController < ApplicationController
    
    def create_game
        game = Game.create
        if game.valid?
          host_session = Session.create(game_id: game.id)
          render json: { game: game, session: host_session }, status: :created
        else
          render json: game.errors, status: :unprocessable_entity
        end
    end
    

    def join_game
        # create a new session

        # if theyre joining a game, the game should be findable by the game's invite code
        game = Game.find_by(invite_code: params[:invite_code])
    
        if game.valid?
            guest_session = Session.create(game_id: game.id)
    

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



    def deal_card
        game = Game.find(params[:game_id])
        validate_session_number_for_card_deal!(game)
        player = Player.find(params[:player_id])
        session = Session.find(params[:session_id])

        session.update(current_player: player)

        
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
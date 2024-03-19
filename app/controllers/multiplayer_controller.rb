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


    def draw_card
        game = Game.find_by(id: params[:game_id])
        validate_session_number_for_gameplay!(game)

        player = Player.all.sample
        session = Session.find(params[:session_id])

        session.update(current_player: player)
        session.increment!(:refreshes)

        # don't need to broadcast the card draw, just the card deal, because only the current player can draw a card and know what it is
        render json: {player: player,refreshes_left: session.refreshes_left}, status: :ok
    end

    def current_sessions_state
      # did i draw a card?
      # did my opponent deal a card?
      # did i deal a card?
      game = Game.find(params[:game_id])
      sessions = game.sessions
      session1 = sessions.first
      session2 = sessions.second

      session1_card = session1.current_player
      session2_card = session2.current_player

      session1_dealt = session1.card_dealt
      session2_dealt = session2.card_dealt

      render json: { session1: { id: session1.id, card: session1_card, dealt: session1_dealt }, session2: { id: session2.id, card: session2_card, dealt: session2_dealt } }, status: :ok

    end

    def current_score
        game = Game.find(params[:game_id])
        session = Session.find(params[:session_id])

        current_session_score = game.sessions.find(session.id).current_score

        opponent_score = game.sessions.where.not(id: session.id).first.current_score

        render json: { my_score: current_session_score, opponent_score: opponent_score }, status: :ok

    end

    # weird way of saying 'deal card' but need to be clear that we're flipping an important 'card dealt' flag
    def send_card_dealt
        game = Game.find(params[:game_id])
        validate_session_number_for_gameplay!(game)

        
        session = Session.find(params[:session_id])
        current_player = session.current_player

        if current_player.nil?
            return render json: { error: "User must draw a player before dealing" }, status: :unprocessable_entity
        end

        
        ActionCable.server.broadcast(
            "GameChannel",
            {id: game.id, action: 'card_dealt', player: current_player, session: session}
        )

        session.update!(card_dealt: true)

        # problem: 
        #  1. we draw a card
        # 2. opponent draws and sends a card
        # we get an error sending because rails thinks we're sending a get request when deal_card is a post request
        # this is why! 
        #  now there is a difference between 'card drawn' and 'card dealt'
        # card drawn is when the player draws a card, and only they know what it is, but it is tied to the session
        # so the round thinks that both players have dealt simply by having a player attached to the session
        # when in reality they need the card_dealt flag to be true
        battle_response = {ready: false}
        if game.both_cards_dealt?
            winner_loser =  game.handle_current_round!
            battle_response[:ready] = true
            battle_response.merge!(**winner_loser)
        end

        render json: { message: "Card dealt", battle_response: battle_response }, status: :ok
    end

    private

    def validate_session_number_for_gameplay!(game)
      if !game || game.sessions.count != 2
        # this is possible when both users join a game, but one of them leaves before the game ends (when the other user is dealing a card)
        # so we need to tell the user the game is invalid
          ActionCable.server.broadcast("GameChannel", { action: 'invalid_game', id: game.id })
          return render json: { error: "Invalid number of sessions" }, status: :unprocessable_entity
      end
    end
     
    
end
class GamesController < ApplicationController
     def destroy
        game = Game.find_by(id: params[:id])
        return render json: { error: "Game not found" }, status: :not_found if game.nil?
        return render json: game.errors, status: :unprocessable_entity unless game.valid?

        game.destroy
        render json: { message: "Game deleted" }, status: :ok
    end

    def restart
         game = Game.find_by(id: params[:id])
         return render json: { error: "Game not found" }, status: :not_found if game.nil?
         return render json: game.errors, status: :unprocessable_entity unless game.valid?
         requesting_session = Session.find_by(id: params[:session_id])

         return render json: { error: "Session not found" }, status: :not_found if requesting_session.nil?

         return render json: { error: "Unauthorized" }, status: :unauthorized if game.sessions.exclude?(requesting_session)


         requesting_session.update(game_ready: true)

         game.reload

         if game.both_sessions_game_ready?
            ActionCable.server.broadcast("GameChannel", { action: 'game_restart', id: game.id })
            render json: { message: "Game restarted" }, status: :ok
         else
            ActionCable.server.broadcast("GameChannel", { action: 'rematch_requested', id: game.id, requesting_session: requesting_session})
            render json: { message: "Rematch requested" }, status: :ok
         end

      rescue StandardError => e
         render json: { error: e.message }, status: :internal_server_error
    end


     private 

     def delete_params
        params.permit()
     end
end
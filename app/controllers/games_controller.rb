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

         game.sessions.each do |session|
             session.update(current_score: 0, card_dealt: false, current_player: nil)
         end

         # will in the future have functionality to have other player accept rematch
         GameChannel.broadcast_to(game, { id: game.id, action: "game_restart" })

         render json: { message: "Game restarted" }, status: :ok

      rescue StandardError => e
         render json: { error: e.message }, status: :internal_server_error
     end
    end


     private 

     def delete_params
        params.permit()
     end
end
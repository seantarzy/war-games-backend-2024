class GamesController < ApplicationController
     def destroy
        game = Game.find_by(id: params[:id])
        return render json: { error: "Game not found" }, status: :not_found if game.nil?
        return render json: game.errors, status: :unprocessable_entity unless game.valid?

        game.destroy
        render json: { message: "Game deleted" }, status: :ok
    end

     private 

     def delete_params
        params.permit()
     end
end
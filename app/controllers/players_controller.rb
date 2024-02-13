class PlayersController < ApplicationController

    def index
        players = Player.all
        render json: players
    end

    def show
        player = Player.find(params[:id])
        render json: player
    end

    def show_random
        player = Player.all.sample
        render json: player
    end
end

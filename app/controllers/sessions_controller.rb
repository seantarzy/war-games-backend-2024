class SessionsController < ApplicationController
    def destroy
        session = Session.find_by(id: params[:id])
        return render json: { error: "Session not found" }, status: :not_found if session.nil?
        return render json: session.errors, status: :unprocessable_entity unless session.valid?

        session.destroy
        render json: { message: "Session deleted" }, status: :ok
    end

    def refreshes_left
        session = Session.find_by(id: params[:id])
        return render json: { error: "Session not found" }, status: :not_found if session.nil?
        return render json: session.errors, status: :unprocessable_entity unless session.valid?

        render json: { refreshes: session.refreshes_left }, status: :ok
    end
end
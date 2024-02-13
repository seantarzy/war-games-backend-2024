class GameChannel < ApplicationCable::Channel
  def subscribed
   stream_from "GameChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Custom action
  def send_move(data)
    ActionCable.server.broadcast("GameChannel", { action: 'move', move: data['move'] })
  end
end

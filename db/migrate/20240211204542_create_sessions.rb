class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.integer :current_score, default: 0
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :game_id

      t.timestamps
    end
  end
end

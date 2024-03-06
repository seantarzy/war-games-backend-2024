class CreateSessionGames < ActiveRecord::Migration[7.1]
  def change
    create_table :session_games do |t|
      t.references :session, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.references :current_player, null: true, foreign_key: { to_table: :players }
      t.integer :current_score, default: 0
      t.boolean :active, default: false

      t.integer :refreshes, default: 0
      
      t.timestamps
    end
  end
end

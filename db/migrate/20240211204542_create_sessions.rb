class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.integer :current_score, default: 0
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.references :game, foreign_key: true

      t.references :current_player, foreign_key: { to_table: :players }, null: true

      t.timestamps
    end
  end
end
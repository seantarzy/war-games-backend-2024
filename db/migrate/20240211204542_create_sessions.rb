class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.integer :wins, default: 0
      t.integer :losses, default: 0

      t.timestamps
    end
  end
end
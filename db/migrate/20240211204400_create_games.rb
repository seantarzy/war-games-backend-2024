class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :invite_code

      t.timestamps
    end
  end
end

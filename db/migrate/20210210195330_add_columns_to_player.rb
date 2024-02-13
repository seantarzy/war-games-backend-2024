class AddColumnsToPlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :wins, :string
    add_column :players, :losses, :string
    add_column :players, :era, :string
    add_column :players, :strikeouts, :string
    add_column :players, :ip, :string
    add_column :players, :saves, :string
    add_column :players, :at_bats, :string
    add_column :players, :hits, :string
    add_column :players, :avg, :string
    add_column :players, :hr, :string
    add_column :players, :runs, :string
    add_column :players, :rbi, :string
    add_column :players, :stolen_bases, :string
  end
end

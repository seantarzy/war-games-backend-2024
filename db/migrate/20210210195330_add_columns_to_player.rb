class AddColumnsToPlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :wins, :integer
    add_column :players, :losses, :integer
    add_column :players, :era, :float
    add_column :players, :strikeouts, :integer
    add_column :players, :ip, :float
    add_column :players, :saves, :integer
    add_column :players, :at_bats, :integer
    add_column :players, :hits, :integer
    add_column :players, :avg, :float
    add_column :players, :hr, :integer
    add_column :players, :runs, :integer
    add_column :players, :rbi, :integer
    add_column :players, :stolen_bases, :integer
    add_column :players, :walks, :integer
    add_column :players, :doubles, :integer
    add_column :players, :triples, :integer
    add_column :players, :slg_pct, :float
    add_column :players, :obs, :float
    add_column :players, :shutouts, :integer
    add_column :players, :caught_stealing, :integer
    add_column :players, :steals, :integer
    

  end
end

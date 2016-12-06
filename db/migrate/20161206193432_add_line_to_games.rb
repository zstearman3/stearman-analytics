class AddLineToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :spread, :float
    add_column :games, :moneyline, :float
    add_column :games, :homecalc, :float
    add_column :games, :awaycalc, :float
    add_column :games, :spreaddiff, :float
    add_column :games, :mldiff, :float
  end
end

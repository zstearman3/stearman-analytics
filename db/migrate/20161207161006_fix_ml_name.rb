class FixMlName < ActiveRecord::Migration[5.0]
  def change
    rename_column :games, :moneyline, :overunder
    rename_column :games, :mldiff, :oudiff
  end
end

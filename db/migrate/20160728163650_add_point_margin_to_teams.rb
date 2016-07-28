class AddPointMarginToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :point_margin, :decimal
  end
end

class AddInitortgToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :initortg, :decimal
    add_column :teams, :initdrtg, :decimal
  end
end

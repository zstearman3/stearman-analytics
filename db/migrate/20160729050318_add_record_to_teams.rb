class AddRecordToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :wins, :integer
    add_column :teams, :losses, :integer
    add_column :teams, :conf_wins, :integer
    add_column :teams, :conf_losses, :integer
  end
end

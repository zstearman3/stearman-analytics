class AddRankToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :rank, :integer
  end
end

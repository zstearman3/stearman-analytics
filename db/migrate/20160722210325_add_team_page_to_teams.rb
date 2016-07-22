class AddTeamPageToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :team_page, :string
  end
end

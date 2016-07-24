class AddSchedulePageToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :schedule_page, :string
  end
end

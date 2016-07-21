class CreateTeamGames < ActiveRecord::Migration[5.0]
  def change
    create_table :team_games do |t|
      t.datetime :date
      t.integer :home_score
      t.integer :away_score
      t.boolean :neutral
      t.boolean :overtime
      t.string :home_team, foreign_key: true, index: true
      t.string :away_team, foreign_key: true, index: true
      t.timestamps
    end
  end
end

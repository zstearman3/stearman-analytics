class CreatePlayerGames < ActiveRecord::Migration[5.0]
  def change
    create_table :player_games do |t|
      t.datetime :date
      t.integer  :points
      t.integer  :rebounds
      t.integer  :assists
      t.references :player, foreign_key: true
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end

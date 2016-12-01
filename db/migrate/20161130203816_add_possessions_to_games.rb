class AddPossessionsToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :posessions, :integer
  end
end

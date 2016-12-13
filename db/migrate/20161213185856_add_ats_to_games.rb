class AddAtsToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :ats, :string
  end
end

class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.text :name
      t.float :rating
      t.float :ortg
      t.float :drtg
      t.references :team, foreign_key: true

      t.timestamps
    end
    add_index :players, [:team_id, :rating]
  end
end

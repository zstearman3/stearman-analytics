class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :school_name
      t.string :nickname
      t.numeric :rating
      t.numeric :ortg
      t.numeric :drtg
      t.numeric :tempo

      t.timestamps
    end
  end
end

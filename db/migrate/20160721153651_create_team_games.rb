class CreateTeamGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.datetime :date
      t.integer :home_score
      t.integer :away_score
      t.string :neutral
      t.integer :overtime
      t.string :home_team
      t.string :away_team
      
      t.timestamps
    end
    
    # create_table :teams do |t|
    #   t.string :school_name, index: true
    #   t.string :nickname
    #   t.numeric :rating
    #   t.numeric :ortg
    #   t.numeric :drtg
    #   t.numeric :tempo

    #   t.timestamps
    # end
    
    create_table :games_teams, id: false do |t|
      t.belongs_to :game, index: true
      t.belongs_to :team, index: true
    end
  end
end

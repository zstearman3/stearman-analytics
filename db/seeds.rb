# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

@Oklahoma = Team.create!(school_name: "Oklahoma",
             rating:      "100.1")
             
             
Team.create!(school_name: "Kansas",
             rating:      "104.3")
             
@Texas = Team.create!(school_name: "Texas",
             rating:      "98.1")
             
TeamGame.create!(date:       "02/08/2016",
                 home_score: 63,
                 away_score: 60,
                 neutral:    false,
                 overtime:   false,
                 home_team:  @Oklahoma,
                 away_team:  @Texas)
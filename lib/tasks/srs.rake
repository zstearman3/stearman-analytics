namespace :srs do
  
  desc "Tasks to populate rate teams using SRS"
  
  task :simple_rating => :environment do
    Team.all.each do |team|
      team.rating = team.point_margin
      team.save
      puts team.rating
    end
    1.times do
    error = 0
      Team.all.each do |team|
        current_team = Team.find_by(school_name: team.school_name)
        opp_rating = 0
        team.games.each do |game|
        
          if team.school_name = game[:home_team]
            opponent = game[:away_team]
          else
            opponent = game[:home_team]
          end
          opp_team = Team.find_by(school_name: opponent)
          if !opp_team.nil?
            opp_rating += opp_team.rating
          end
        end
        if team.games.count != 0
          oldrating = current_team.rating
          current_team.rating = current_team.rating + ((1.0/(team.games.count)) * opp_rating)
          current_team.rating = current_team.rating.round(1)
          current_team.save
          error = error + (current_team.rating - oldrating).abs
          error = error.round(1)
        end
      end
      puts error
    end
  end
end
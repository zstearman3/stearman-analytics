class Team < ApplicationRecord
  has_many :team_games
  
  def games
    TeamGame.where('home_team = ? OR away_team = ?', id, id)
  end
end

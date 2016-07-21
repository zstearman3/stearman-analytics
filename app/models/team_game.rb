class TeamGame < ApplicationRecord
  belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team'
  belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team'
end

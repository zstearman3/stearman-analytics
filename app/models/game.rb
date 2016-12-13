class Game < ApplicationRecord
  has_and_belongs_to_many :teams
  has_many :player_games
end

class Team < ApplicationRecord
  def to_param
    school_name
  end
  has_and_belongs_to_many :games
  has_many :players
end

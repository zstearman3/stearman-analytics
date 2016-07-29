# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

teams_text = File.read(Rails.root.join('lib', 'seeds', '2016Teams.csv'))
csv = CSV.parse(teams_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |team|
  puts team.to_hash
  t = Team.new
  t.school_name = team['school_name']
  t.nickname = team['nickname']
  t.conference = team['conference']
  t.save
  puts "#{t.school_name} saved"
end

puts "There are now #{Team.count} teams in the database"

schedule_text = File.read(Rails.root.join('lib', 'seeds', '2016Schedule.csv'))
csv = CSV.parse(schedule_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |game|
  t = Game.new
  t.date = Date.strptime(game['date'], "%m/%d/%Y")
  t.home_team = game['home_team']
  t.away_team = game['away_team']
  t.home_score = game['home_score']
  t.away_score = game['away_score']
  t.neutral = game['neutral']
  t.overtime = game['overtime'] || 0
  hometeam = Team.find_by(school_name: game['home_team'])
  awayteam = Team.find_by(school_name: game['away_team'])
  if !hometeam.nil? && !awayteam.nil?
    t.teams = Team.where(:school_name => [game['home_team'], game['away_team']])
    t.save
  end
  if !hometeam.nil? && !awayteam.nil?
    margin = game['home_score'].to_i - game['away_score'].to_i
    hometeam.point_margin ||= 0
    awayteam.point_margin ||= 0
    hometeam.point_margin += margin
    awayteam.point_margin -= margin
    hometeam.wins ||= 0
    hometeam.losses ||= 0
    hometeam.conf_wins ||= 0
    hometeam.conf_losses ||= 0
    awayteam.wins ||= 0
    awayteam.losses ||= 0
    awayteam.conf_wins ||= 0
    awayteam.conf_losses ||= 0
    if margin > 0 
      hometeam.wins += 1
      awayteam.losses += 1
    else
      awayteam.wins += 1
      hometeam.losses += 1
    end
    if hometeam.conference == awayteam.conference
      if margin > 0 
        hometeam.conf_wins += 1
        awayteam.conf_losses += 1
      else
        awayteam.conf_wins += 1
        hometeam.conf_losses += 1
      end
    end
    hometeam.save
    awayteam.save
    puts hometeam.nickname + " has a point margin of #{hometeam.point_margin}"
  end
end

puts "There are now #{Game.count} games in the database"
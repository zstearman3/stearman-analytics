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
  t.teams = Team.where(:school_name => [game['home_team'], game['away_team']])
  t.save
end

puts "There are now #{Game.count} games in the database"
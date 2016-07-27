namespace :ncaa_csv do
  require 'nokogiri'
  require 'open-uri'
  #look into using http://www.sports-reference.com/cbb
  
  desc "Tasks to populate database with current NCAA Div 1 teams"
  
  task :fetch_teams => :environment do
    
  end
end
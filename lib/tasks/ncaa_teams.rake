namespace :ncaa_teams do
  
  desc "Tasks to populate database with current NCAA Div 1 teams"
  
  task :fetch_teams => :environment do
    require 'nokogiri'
    require 'open-uri'
    
    url = "http://espn.go.com/mens-college-basketball/teams"
    doc = Nokogiri::HTML(open(url))
    puts doc.at_css("title").text
    doc.css(".mod-content h5").each do |team|
      school =  team.text
      team_page = team.css('a').first.attr('href')
      Team.create_with(team_page: team_page).find_or_create_by(school_name: school)
    end
  end
  
  task :get_nicknames => :environment do
    require 'nokogiri'
    require 'open-uri'
    Team.all.each do |team|
      begin
        url = team.team_page
        doc = Nokogiri::HTML(open(url))
        nickname = doc.css(".team-name .link-text").first.text
        nickname.slice! team.school_name
        nickname.strip!
        team.nickname = nickname
        team.save
      rescue
        team.nickname = "River Hawks"
        team.save
        puts team.school_name " did not load correctly."
      end
    end
  end
end

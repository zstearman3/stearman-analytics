namespace :ncaa_teams do
  require 'nokogiri'
  require 'open-uri'
  #look into using http://www.sports-reference.com/cbb
  
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
        schedule = url.gsub('_/', 'schedule/_/year/2016/')
        doc = Nokogiri::HTML(open(url))
        nickname = doc.css(".team-name .link-text").first.text
        nickname.slice! team.school_name
        nickname.strip!
        team.nickname = nickname
        team.schedule_page = schedule
        puts schedule
        team.save
      rescue
        team.nickname = "River Hawks"
        team.schedule_page = "http://espn.go.com/mens-college-basketball/team/schedule/_/id/2349/year/2016/"
        team.save
        # puts team.school_name " did not load correctly."
      end
    end
  end
  
  task :get_schedules => :environment do
    #Team.all.each do |team|
    team = Team.first
    puts team
    url = 'http://www.cbssports.com/collegebasketball/scoreboard/div1/20161111'
    doc = Nokogiri::HTML(open(url))
    doc = doc.css(".scoreBox").first(3).each do |game|
      game = game.css('.gameTracker').attr('href')
      game = 'http://www.cbssports.com' + game
      game = Nokogiri::HTML(open(game))
      x = 0
      away = ""
      home = ""
      game = game.css('.data').each do |gteam|
        if x == 0
          away = gteam.css('.title').text
        else
          home = gteam.css('.title').text
        end
        x = x + 1
      end
      x = 0
    #   headless.start
    #   browser = Watir::Browser.new
    puts away + ' @ ' + home
    #  headless.destroy
    end
  end
end

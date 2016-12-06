namespace :ncaa_teams do
  require 'nokogiri'
  require 'open-uri'
  require 'date'
  #look into using http://www.sports-reference.com/cbb
  
  desc "Tasks to populate database with current NCAA Div 1 teams"
  
  task :fetch_teams => :environment do
    # This task will completely erase the database of teams and create them
    # again from scratch using the cbssports list of teams. This is only meant
    # to be performed once.
    
    require 'nokogiri'
    require 'open-uri'
    Player.delete_all    
    Team.delete_all
    url = "http://www.cbssports.com/college-basketball/teams/"
    doc = Nokogiri::HTML(open(url))
    
    x = 0
    conf = 'blank'
    doc.css("table .data").each do |conference|
      conference.css('tr').each do |team|
        if x == 0
          conf = team.text
          puts 'Conference = ' + conf
        else
          if team.at_css('a')
            school = team.text
            team_page = 'http://www.cbssports.com' + team.css('a').first.attr('href')
            team = Team.create_with(team_page: team_page, conference: conf).find_or_create_by(school_name: school)
            doc = Nokogiri::HTML(open(team_page))
            nickname = doc.css('title').text
            nickname.slice! school
            nickname.slice! '- NCAA Basketball - CBSSports.com'
            nickname.strip!
            team.nickname = nickname
            team.conference = conf
            team.save
            roster_page = team_page.dup
            roster_page.slice! 'http://www.cbssports.com/collegebasketball/teams/page/'
            roster_page = 'http://www.cbssports.com/collegebasketball/teams/roster/' + roster_page
            puts roster_page
            doc = Nokogiri::HTML(open(roster_page))
            doc = doc.css('.col-8 .data').first
            doc.css('.row1').each do |roster|
              num = ""
              name = ""
              pos = ""
              y = 0
              roster.css('td').each do |value|
                if y == 0
                  num = value.text
                elsif y == 1
                  name = value.text
                  puts name
                elsif y == 2
                  pos = value.text
                end
                y = y + 1
              end
              team.players.create_with(name: name).find_or_create_by(name: name)
              team.save
            end

            doc.css('.row2').each do |roster|
              num = ""
              name = ""
              pos = ""
              y = 0
              roster.css('td').each do |value|
                if y == 0
                  num = value.text
                elsif y == 1
                  name = value.text
                  puts name
                elsif y == 2
                  pos = value.text
                end
                y = y + 1
              end
              team.players.create_with(name: name).find_or_create_by(name: name)
              team.save
            end
          end
        end
        x += 1
      end
      x = 0
    end
    
    # create dummy div 2 team
    Team.create_with(team_page: "", conference: 'n/a', school_name: 'dummy', nickname: '').find_or_create_by(school_name: school)
  end
  
  task :get_schedules => :environment do
    #This task is meant to be run after the teams have been created. It will 
    #get box scores for all games up to todays date and fill in the stats for each
    #team. This will overwrite old scores.
    Game.delete_all
    Team.all.each do |team|
      team.point_margin = 0
      team.wins = 0
      team.losses = 0
      team.conf_wins = 0
      team.conf_losses = 0
      team.tempo = 69.6
      team.save
    end
    
    #Run with last year's games first to get starting ratings.
    #(Date.new(2015, 11, 13)..Date.new(2016, 4, 4)).each do |date|
    (Date.new(2016, 11, 11)..Date.yesterday).each do |date|
      urldate = date.strftime("%Y%m%d")
      url = 'http://www.cbssports.com/collegebasketball/scoreboard/div1/' + urldate
      doc = Nokogiri::HTML(open(url))
      puts doc.css('title')
      doc.css('.scoreBox').each do |game|
        if game.at_css('.gameExtras a')
          @awayteam = game.css('.awayTeam .teamLocation').text
          @awayteam.slice! game.css('.awayTeam .teamLocation .teamRecord').text
          if game.at_css('.awayTeam span')
            @awayteam.slice! game.css('.awayTeam span').text
          end
          @awayscore = game.css('.awayTeam .finalScore').text
          @hometeam = game.css('.homeTeam .teamLocation').text
          @hometeam.slice! game.css('.homeTeam .teamLocation .teamRecord').text
          if game.at_css('.homeTeam span')
            @hometeam.slice! game.css('.homeTeam span').text
          end
          @homescore = game.css('.homeTeam .finalScore').text
          @t = Game.new
          @t.date = date
          @t.home_team = @hometeam
          @t.away_team = @awayteam
          @t.home_score = @homescore
          @t.away_score = @awayscore
          @t.overtime = 0
          if game.css('.gameExtras a').text.include? 'Box Score'
            hometeam = Team.find_by(school_name: @hometeam)
            awayteam = Team.find_by(school_name: @awayteam)
            gameurl = 'http://www.cbssports.com' + game.css('.gameExtras a').first.attr('href')
            doc = Nokogiri::HTML(open(gameurl))
            fga = 0
            tov = 0
            fta = 0
            oreb = 0
            doc.css('.data #totals').each do |totals|
              shots = totals.xpath('./td[3]').text
              freethrows = totals.xpath('./td[5]').text
              turnovers = totals.xpath('./td[9]').text.to_i
              offreb = totals.xpath('./td[6]').text.to_i
              fga += shots.partition('-').last.to_i
              fta += freethrows.partition('-').last.to_i
              tov += turnovers
              oreb += offreb
              totals.remove
            end
            poss = 0.48 * (fga + tov + (0.475 * fta) - oreb)
            @t.posessions =  poss
            Rake::Task['ncaa_teams:create_game'].execute
            doc.css('.data #head, .data #pct, .data .title').each do |trash|
              trash.remove
            end
            doc.css('.data tr').each do |player|
              # name = player.css('a').text
              # puts player
            end
          else
            hometeam = Team.find_by(school_name: @hometeam)
            awayteam = Team.find_by(school_name: @awayteam)
            if hometeam && awayteam
              puts hometeam.school_name
              poss = (hometeam.tempo * awayteam.tempo)/69.0
              @t.posessions = poss
              Rake::Task['ncaa_teams:create_game'].execute
            end
          end
        end
      end
    end
  end
  
  task :create_game => :environment do
    hometeam = Team.find_by(school_name: @hometeam)
    awayteam = Team.find_by(school_name: @awayteam)
    if !hometeam.nil? && !awayteam.nil?
      @t.teams = hometeam, awayteam
      @t.save
     elsif !hometeam.nil?
      @t.teams = hometeam, Team.find_by(school_name: 'dummy')  
      #@t.save
     elsif !awayteam.nil?
      @t.teams = awayteam, Team.find_by(school_name: 'dummy')
      #@t.save
    end
    if !hometeam.nil? && !awayteam.nil?
      margin = @homescore.to_i - @awayscore.to_i
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
    end
  end
  #   team = Team.first
  #   puts team
  #   url = 'http://www.cbssports.com/collegebasketball/scoreboard/div1/20161111'
  #   doc = Nokogiri::HTML(open(url))
  #   doc = doc.css(".scoreBox").first(3).each do |game|
  #     game = game.css('.gameTracker').attr('href')
  #     game = 'http://www.cbssports.com' + game
  #     game = Nokogiri::HTML(open(game))
  #     x = 0
  #     away = ""
  #     home = ""
  #     game = game.css('.data').each do |gteam|
  #       if x == 0
  #         away = gteam.css('.title').text
  #       else
  #         home = gteam.css('.title').text
  #       end
  #       x = x + 1
  #     end
  #     x = 0
  #   #   headless.start
  #   #   browser = Watir::Browser.new
  #   puts away + ' @ ' + home
  #   #  headless.destroy
  #   end
  
end  
  
######################### OLD WORK BELOW #######################################

    # This task has been depricated
  # task :get_nicknames => :environment do
  #   require 'nokogiri'
  #   require 'open-uri'
  #   Team.all.each do |team|
  #     begin
  #       url = team.team_page
  #       schedule = url.gsub('_/', 'schedule/_/year/2016/')
  #       doc = Nokogiri::HTML(open(url))
  #       nickname = doc.css(".team-name .link-text").first.text
  #       nickname.slice! team.school_name
  #       nickname.strip!
  #       team.nickname = nickname
  #       team.schedule_page = schedule
  #       puts schedule
  #       team.save
  #     rescue
  #       team.nickname = "River Hawks"
  #       team.schedule_page = "http://espn.go.com/mens-college-basketball/team/schedule/_/id/2349/year/2016/"
  #       team.save
  #       # puts team.school_name " did not load correctly."
  #     end
  #   end
  # end
  


namespace :srs do
  
  desc "Tasks to populate rate teams using SRS"
  
    task :update_schedules => :environment do
    #This task is meant to be run after the teams have been created. It will 
    #get box scores for all games up to todays date and fill in the stats for each
    #team. This will overwrite old scores.

    #Run with last year's games first to get starting ratings.
    #(Date.new(2015, 11, 13)..Date.new(2016, 4, 4)).each do |date|
    startdate = Game.last.date.to_date # + 1.day
    (startdate..Date.yesterday).each do |date|
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
            poss = 0.48 * (fga + tov + (0.44 * fta) - oreb)
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
              poss = (hometeam.tempo + awayteam.tempo)/2
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
  
  task :simple_rating => :environment do
    Team.all.each do |team|
      if team.games.count != 0
        team.rating = (team.point_margin/ (4 * team.games.count))
        team.ortg = 101
        team.drtg = 101
        team.save
      else team.rating = 0
      end
    end
    3.times do
    error = 0
      Team.all.each do |team|
        current_team = Team.find_by(school_name: team.school_name)
        opp_rating = 0
        team.games.each do |game|
        
          if team.school_name = game[:home_team]
            opponent = game[:away_team]
            teamscore = game.home_score
            opponentscore = game.away_score
          else
            opponent = game[:home_team]
            teamscore = game.away_score
            opponentscore = game.home_score
          end
          opp_team = Team.find_by(school_name: opponent)
          if !opp_team.nil?
            opp_rating += opp_team.rating
            opp_tempo = opp_team.tempo
            opp_ortg = opp_team.ortg
            opp_drtg = opp_team.drtg
            if game.posessions
              current_team.tempo = current_team.tempo - ((((current_team.tempo + opp_tempo)/2.00) - game.posessions)/4.00)
              current_team.tempo = current_team.tempo.round(2)
              current_team.ortg = current_team.ortg - ((((current_team.ortg + opp_drtg)/2) - (teamscore * (100.00/game.posessions)))/6)
              current_team.ortg = current_team.ortg.round(2)
              current_team.drtg = current_team.drtg - ((((current_team.drtg + opp_ortg)/2) - (opponentscore * (100.00/game.posessions)))/6)
              current_team.drtg = current_team.drtg.round(2)
              current_team.save
            end
          end
        end
        if team.games.count != 0
          oldrating = current_team.rating
          current_team.rating = ((current_team.ortg - 100) + (100 - current_team.drtg))/2
          current_team.rating = current_team.rating.round(1)
          rank = Team.where("rating > ?", current_team.rating).count + 1
          current_team.rank = rank
          current_team.save
          error = error + (current_team.rating - oldrating).abs
          error = error.round(1)
        end
      end
      puts Team.first.rating
      puts error
    end
    Team.all.each do |team|
      current_team = Team.find_by(school_name: team.school_name)
      rank = Team.where("rating > ?", current_team.rating).count + 1
      current_team.rank = rank
      current_team.save
    end
  end
end
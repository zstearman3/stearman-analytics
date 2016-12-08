namespace :srs do
  
  desc "Tasks to populate schedules and rate teams using new rating system"
  
  task :update_schedules => :environment do
  #This task is meant to be run after the teams have been created. It will 
  #get box scores for all games for the last three days in the database up to
  #today and fill in the stats for each team. This will overwrite old scores 
  #for these dates. If you need to update scores from longer than 3 days before
  #the last update, you must run the get schedules task.

  #Run with last year's games first to get starting ratings.
  #(Date.new(2015, 11, 13)..Date.new(2016, 4, 4)).each do |date|
  
  startdate = Game.order(date: :asc).last.date.to_date - 3.days
    (startdate..Date.yesterday).each do |date|
      #For each date, we must select each game and determine if the game has already
      #been added to the database.
      urldate = date.strftime("%Y%m%d")
      url = 'http://www.cbssports.com/collegebasketball/scoreboard/div1/' + urldate
      doc = Nokogiri::HTML(open(url))
      puts doc.css('title')
      doc.css('.scoreBox').each do |game|
        # Every game will be selected here, whether a box score is present or not.
        if game.at_css('.gameExtras a')
          # This if just gets rid of phony .scoreBox tags.
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
          @overtime = 0 # I need to find a way to take OT values from this page still
          @neutral = "false" # I can't determine if games are on a neutral court yet
          hometeam = Team.find_by(school_name: @hometeam)
          awayteam = Team.find_by(school_name: @awayteam)
          # We have everything we need for the calculations already except tempo
          if game.css('.gameExtras a').text.include? 'Box Score'
            # Now, select the games where a box score has been linked
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
            @posessions = 0.48 * (fga + tov + (0.475 * fta) - oreb)
            doc.css('.data #head, .data #pct, .data .title').each do |trash|
              trash.remove
              #clears out data not needed to get player stats
            end
            doc.css('.data tr').each do |player|
              # Need to determine how to scrape this data still.
              # name = player.css('a').text
              # puts player
            end
          else
            # If no box score was present, we still don't have a value for possessions
            if hometeam && awayteam
              @posessions = (hometeam.tempo * awayteam.tempo)/69.0 #69.0 represents NCAA average
              #69.0 needs to be tuned or I need to truly find the NCAA average here
            end
          end
          # We are now outside of the if concerning the box scores. Every game will go through
          # these lines of code. We need to determine if we will update the game or create a new one
          # here. 
          updatedgame = nil
          Game.where(:date => date).find_each do |oldgame|
            if oldgame.home_team == @hometeam || oldgame.away_team == @awayteam
              updatedgame = oldgame
            end
          end
          if updatedgame
            # update a game that has already been created
            updatedgame.home_score = @homescore
            updatedgame.away_score = @awayscore
            updatedgame.posessions = @posessions
            updatedgame.overtime = @overtime
            updatedgame.neutral = @neutral
            updatedgame.save
          else
            # create a new game
            @t = Game.new
            @t.date = date
            @t.home_team = @hometeam
            @t.away_team = @awayteam
            @t.home_score = @homescore
            @t.away_score = @awayscore
            @t.posessions = @posessions
            @t.overtime = @overtime
            @t.neutral = @neutral
            if hometeam && awayteam # fill in dummy for DII teams
              @t.teams = hometeam, awayteam
              @t.save
            elsif !hometeam.nil?
              @t.teams = hometeam, Team.find_by(school_name: 'dummy')  
              @t.save
            elsif !awayteam.nil?
              @t.teams = awayteam, Team.find_by(school_name: 'dummy')
              @t.save
            end
          end
        end
      end
      # closes each game so this part of the code is only ran at the end of the
      # collection process but still for each day.
    end
    # closes each day so this will only run once after all games have been updated.
  end

  
  task :betting_predictions => :environment do
    # This task will only look at the CBS Sports games for Today in stystem time.
    # Will try to get game lines for these games, make predictions, and compare
    # predicted score to Vegas score. Maybe I should extend this to future games
    # as well?
    
    urldate = Date.today.strftime("%Y%m%d")
    url = 'http://www.cbssports.com/collegebasketball/scoreboard/div1/' + urldate
    doc = Nokogiri::HTML(open(url))
    puts doc.css('title')
    doc.css('.scoreBox').each do |game|
      @awayteam = game.css('.awayTeam .teamLocation').text
      @awayteam.slice! game.css('.awayTeam .teamLocation .teamRecord').text
      if game.at_css('.awayTeam span')
        @awayteam.slice! game.css('.awayTeam span').text
      end
      @hometeam = game.css('.homeTeam .teamLocation').text
      @hometeam.slice! game.css('.homeTeam .teamLocation .teamRecord').text
      if game.at_css('.homeTeam span')
        @hometeam.slice! game.css('.homeTeam span').text
      end
      hometeam = Team.find_by(school_name: @hometeam)
      awayteam = Team.find_by(school_name: @awayteam) 
      @overunder = game.css('.awayTeam .gameOdds').text
      @overunder.slice! 'O/U'
      @overunder.strip!.to_f
      @spread = game.css('.homeTeam .gameOdds').text.to_f
      existing = nil
      Game.where(:date => Date.today).find_each do |oldgame|
        if oldgame.home_team == @hometeam || oldgame.away_team == @awayteam
          # determine if the game has already been created in the datatbase
          existing = true
        end
      end
      if existing
        # if the game has been created, find it, and update it
        Game.where(:date => Date.today).find_each do |existinggame|
          if existinggame.home_team == @hometeam || existinggame.away_team == @awayteam
            existinggame.overunder = @overunder
            existinggame.spread = @spread
            if hometeam && awayteam
              homescore = (((hometeam.ortg * awayteam.drtg) / (102.0 * 0.99)) * ((hometeam.tempo * awayteam.tempo) / (70.0))) / 100.0
              awayscore = (((awayteam.ortg * hometeam.drtg) / (102.0 * 1.01)) * ((hometeam.tempo * awayteam.tempo) / (70.0))) / 100.0
              existinggame.homecalc = homescore.round(0)
              existinggame.awaycalc = awayscore.round(0)
              existinggame.spreaddiff = (existinggame.awaycalc - existinggame.homecalc) - existinggame.spread
              existinggame.oudiff = (existinggame.awaycalc + existinggame.homecalc) - existinggame.overunder
              existinggame.save
            end
          end
        end
      else
        # if it doesn't exist, create it with the spread and prediction
        @t = Game.new
        @t.date = Date.today
        @t.home_team = @hometeam
        @t.away_team = @awayteam
        @t.overunder = @overunder
        @t.spread = @spread
        if hometeam && awayteam
          @t.teams = hometeam, awayteam
          homescore = (((hometeam.ortg * awayteam.drtg) / (102.0 * 0.99)) * ((hometeam.tempo * awayteam.tempo) / (70.0))) / 100.0
          awayscore = (((awayteam.ortg * hometeam.drtg) / (102.0 * 1.01)) * ((hometeam.tempo * awayteam.tempo) / (70.0))) / 100.0
          @t.homecalc = homescore.round(0)
          @t.awaycalc = awayscore.round(0)
          @t.spreaddiff = (existinggame.awaycalc - existinggame.homecalc) - existinggame.spread
          @t.oudiff = (existinggame.awaycalc + existinggame.homecalc) - existinggame.overunder
          @t.save
        elsif hometeam
          @t.teams = hometeam, Team.find_by(school_name: 'dummy')  
          @t.save
        elsif awayteam
          @t.teams = awayteam, Team.find_by(school_name: 'dummy')
          @t.save
        end
      end
    end
  end
  
  task :simple_rating => :environment do
    3.times do
      error = 0
      Team.all.each do |team|
        if team.ortg == nil
          team.ortg = 102
        end
        if team.drtg == nil
          team.drtg = 102
        end
        if team.tempo == nil
          team.tempo = 69
        end
        team.games.each do |game|
          teamscore = nil
          if team.school_name == game.home_team
            opponent = game.away_team
            teamscore = game.home_score
            opponentscore = game.away_score
          else
            opponent = game.home_team
            teamscore = game.away_score
            opponentscore = game.home_score
          end
          opp_team = Team.find_by(school_name: opponent)
          if opp_team && teamscore && game.posessions
            opp_ortg = opp_team.ortg
            opp_drtg = opp_team.drtg
            opp_tempo = opp_team.tempo
            # 69.0 should be tuned to a better number in the future. 0.15 is a multipier
            # that should be tuned as well when more info is available.
            team.tempo = team.tempo + (0.15 * (game.posessions - (team.tempo * opp_tempo / 69.0)))
            team.tempo = team.tempo.round(2)
                        
            # This handles the team rating for home vs away teams. Home court is simply done by dividing by a multiplier. Will change soon.
            # 0.2 is an arbitrary multiplier. Should change on a game by game basis probably.
            
            if team.school_name == game.home_team
              team.ortg = team.ortg + (0.2 * ((teamscore * (100.0 / game.posessions)) - ((team.ortg * opp_drtg) / (102.0 * 0.99))))
              team.ortg = team.ortg.round(2)
              team.drtg = team.drtg + (0.2 * ((opponentscore * (100.00 /game.posessions)) - ((team.drtg * opp_ortg)/ (102.00 * 1.01))))
              team.drtg = team.drtg.round(2)
            else
              team.ortg = team.ortg + (0.2 * ((teamscore * (100.0 / game.posessions)) - ((team.ortg * opp_drtg) / (102.0 * 1.01))))
              team.ortg = team.ortg.round(2)
              team.drtg = team.drtg + (0.2 * ((opponentscore * (100.00 /game.posessions)) - ((team.drtg * opp_ortg)/ (102.00 * 0.99))))
              team.drtg = team.drtg.round(2)
            end
            team.save
          end
        end
        # All games have been collected now. Still, each team will iterate through
        # this section 3 times. 
        if team.games.count != 0
          oldrating = team.rating || 0
          team.rating = ((team.ortg - 100) + (100 - team.drtg))/2
          team.rating = team.rating.round(1)
          team.save
          error = error + (team.rating - oldrating).abs
          error = error.round(1)
        end
      end
      puts error
    end
    # We are now outside of the 5.times loop, so this section is only performed once at the end.
    Team.all.each do |team|
      team.wins = 0
      team.losses = 0
      team.conf_wins = 0
      team.conf_losses = 0
      @teamname = team.school_name
      team.games.each do |game|
        if game.home_score
          if game.home_team == @teamname
            opponent = Team.find_by(school_name: game.away_team)
            if game.home_score > game.away_score
              team.wins += 1
            else
              team.losses +=1
            end
            if opponent
              if team.conference == opponent.conference
                if game.home_score > game.away_score
                  team.conf_wins += 1
                else
                  team.conf_losses +=1
                end
              end
            end
          else
            opponent = Team.find_by(school_name: game.home_team)
            if game.home_score > game.away_score
              team.losses += 1
            else
              team.wins += 1
            end
            if opponent
              if team.conference == opponent.conference
                if game.home_score > game.away_score
                  team.conf_losses += 1
                else
                  team.conf_wins +=1
                end
              end
            end
          end
        end
      end
      team.save
    end
  end

  
  task :calculate_record => :environment do
    Team.all.each do |team|
      team.wins = 0
      team.losses = 0
      team.conf_wins = 0
      team.conf_losses = 0
      @teamname = team.school_name
      team.games.each do |game|
        if game.home_score
          if game.home_team == @teamname
            opponent = Team.find_by(school_name: game.away_team)
            if game.home_score > game.away_score
              team.wins += 1
            else
              team.losses +=1
            end
            if opponent
              if team.conference == opponent.conference
                if game.home_score > game.away_score
                  team.conf_wins += 1
                else
                  team.conf_losses +=1
                end
              end
            end
          else
            opponent = Team.find_by(school_name: game.home_team)
            if game.home_score > game.away_score
              team.losses += 1
            else
              team.wins += 1
            end
            if opponent
              if team.conference == opponent.conference
                if game.home_score > game.away_score
                  team.conf_losses += 1
                else
                  team.conf_wins +=1
                end
              end
            end
          end
        end
      end
      team.save
    end

  end
end
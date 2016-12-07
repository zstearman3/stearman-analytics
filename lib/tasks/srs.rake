namespace :srs do
  
  desc "Tasks to populate rate teams using SRS"
  
    task :update_schedules => :environment do
    #This task is meant to be run after the teams have been created. It will 
    #get box scores for all games up to todays date and fill in the stats for each
    #team. This will overwrite old scores.

    #Run with last year's games first to get starting ratings.
    #(Date.new(2015, 11, 13)..Date.new(2016, 4, 4)).each do |date|
    startdate = Game.last.date.to_date - 1.day
    (startdate..Date.yesterday).each do |date|
      if Game.find_by(date: date) == nil
        puts ":P first"
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
      else
        if Game.find_by(date: date + 2.days) == nil
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
              @overtime = 0
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
                Game.where(:date => date).find_each do |oldgame|
                  if oldgame.home_team == @hometeam || oldgame.away_team == @awayteam
                  oldgame.home_score = @homescore
                  oldgame.away_score = @awayscore
                  oldgame.posessions = poss
                  oldgame.overtime = @overtime  
                    
                  puts oldgame.home_team
                  oldgame.save
                  end
                end
                doc.css('.data #head, .data #pct, .data .title').each do |trash|
                  trash.remove
                end
                doc.css('.data tr').each do |player|
                  # name = player.css('a').text
                  # puts player
                end
              else
                Game.where(:date => date).find_each do |oldgame|
                  if oldgame.home_team == @hometeam || oldgame.away_team == @awayteam
                  oldgame.home_score = @homescore
                  oldgame.away_score = @awayscore
                  oldgame.posessions = poss
                  oldgame.overtime = @overtime  
                  poss = (hometeam.tempo * awayteam.tempo)/69.0
                  puts oldgame.home_team
                  oldgame.save
                  end
                end
              end
            end
          end
        end
      end
    end
    existing = Game.find_by(date: Date.today)
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
      if existing 
        Game.where(:date => Date.today).find_each do |existinggame|
          if existinggame.home_team == @hometeam || existinggame.away_team == @awayteam
            overunder = game.at_css('.awayTeam .gameOdds').text
            overunder.slice! 'O/U'
            overunder.strip!
            existinggame.moneyline = overunder.to_f
            existinggame.spread = game.css('.homeTeam .gameOdds').text.to_f
            existinggame.home_score = ""
            existinggame.away_score = ""
            hometeam = Team.find_by(school_name: @hometeam)
            awayteam = Team.find_by(school_name: @awayteam)      
            homescore = (((hometeam.ortg * awayteam.drtg) / (102.0 * 0.99)) * ((hometeam.tempo * awayteam.tempo) / (70.0))) / 100.0
            awayscore = (((awayteam.ortg * hometeam.drtg) / (102.0 * 1.01)) * ((hometeam.tempo * awayteam.tempo) / (70.0))) / 100.0
            existinggame.homecalc = homescore.round(0)
            existinggame.awaycalc = awayscore.round(0)
            existinggame.spreaddiff = (existinggame.awaycalc - existinggame.homecalc) - existinggame.spread
            existinggame.mldiff = (existinggame.awaycalc + existinggame.homecalc) - existinggame.moneyline
            existinggame.save
          end
        end
      else
        @t = Game.new
        @t.date = Date.today
        @t.home_team = @hometeam
        @t.away_team = @awayteam
        puts @t
        hometeam = Team.find_by(school_name: @hometeam)
        awayteam = Team.find_by(school_name: @awayteam)
        if hometeam && awayteam
          @t.teams = hometeam, awayteam
          @t.save
         elsif hometeam
          @t.teams = hometeam, Team.find_by(school_name: 'dummy')  
          #@t.save
         elsif awayteam
          @t.teams = awayteam, Team.find_by(school_name: 'dummy')
          #@t.save
        end
        if hometeam && awayteam
          hometeam.save
          awayteam.save
         # do something with your life
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
        team.ortg = 102
        team.drtg = 102
        team.tempo = 70
        team.save
      else team.rating = 0
      end
    end
    5.times do
    error = 0
      Team.all.each do |team|
        current_team = Team.find_by(school_name: team.school_name)
        opp_rating = 0
        team.games.each do |game|
        
          if team.school_name == game[:home_team]
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
              # if current_team.school_name == "Alabama A&M"
              #   puts game[:home_team]
              #   puts game[:away_team]
              #   puts current_team.ortg
              #   puts current_team.drtg
              #   puts opp_ortg
              #   puts opp_drtg
              #   puts teamscore
              #   puts opponentscore
              #   puts game.posessions
              # end
              current_team.tempo = current_team.tempo + (0.15 * (game.posessions - (current_team.tempo * opp_tempo / 70.0)))
              current_team.tempo = current_team.tempo.round(2)
              
              # This handles the team rating for home vs away teams. Home court is simply done by dividing by a multiplier. Will change soon.
              # 0.2 is an arbitrary multiplier. Should change on a game by game basis probably.
              
              if team.school_name == game[:home_team]
                current_team.ortg = current_team.ortg + (0.2 * ((teamscore * (100.00 /game.posessions)) - (current_team.ortg * opp_drtg / (102.00 * 0.99))))
                current_team.ortg = current_team.ortg.round(2)
                current_team.drtg = current_team.drtg + (0.2 * ((opponentscore * (100.00 /game.posessions)) - (current_team.drtg * opp_ortg/ (102.00 * 1.01))))
                current_team.drtg = current_team.drtg.round(2)
              else
                current_team.ortg = current_team.ortg + (0.2 * ((teamscore * (100.00 /game.posessions)) - (current_team.ortg * opp_drtg/ (102.00 * 1.01))))
                current_team.ortg = current_team.ortg.round(2)
                current_team.drtg = current_team.drtg + (0.2 * ((opponentscore * (100.00 /game.posessions)) - (current_team.drtg * opp_ortg/ (102.00 * 0.99))))
                current_team.drtg = current_team.drtg.round(2)
              end
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
class GamesController < ApplicationController
  def show
    @game = Game.find(params[:id])
  end
  
  def predictions
    @date = params[:year].to_s + "/" + params[:month].to_s + "/" + params[:day].to_s
    @games = Game.where(:date => @date)
  end
  
  def results
    @games = Game.where.not(:ats => nil)
  end
end

class GamesController < ApplicationController
  def show
    @game = Game.find(params[:id])
  end
  
  def predictions
  end
end

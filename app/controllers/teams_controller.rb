class TeamsController < ApplicationController
    
  helper_method :games
  
  def index
    @teams = Team.all
  end
  
  def show
    @team = Team.find(params[:id])
  end

end

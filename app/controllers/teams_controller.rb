class TeamsController < ApplicationController
    
  helper_method :games
  
  def index
    @teams = Team.all
  end
  
  def show
    @team = Team.find_by_school_name(params[:id])
  end

end

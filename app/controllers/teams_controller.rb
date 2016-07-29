class TeamsController < ApplicationController
    
  helper_method :games
  
  def index
    @q = Team.ransack(params[:q])
    @q.sorts = 'rank asc'
    @teams = @q.result(distinct: true)
  end
  
  def show
    @team = Team.find_by_school_name(params[:id])
  end

end

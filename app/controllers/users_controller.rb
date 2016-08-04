class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in  @user

      redirect_to @user
      flash[:success] = "Welcome to Stearman Analytics, #{@user.first_name}!"
    else
      render 'new'
    end
  end
  
  
  # -------------Begin private decalrations here--------------
  private
  
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, 
                                   :password, :password_confirmation)
    end
end

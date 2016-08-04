require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before :each do
    @user = create(:user)
  end
  
  describe "Log in and log out" do
    before :each do
      begin
        @customer_attributes = {session: { email: @user.email,
                                  password: @user.password }}
        post :create, @customer_attributes
      rescue
        puts params[:session]
      end
    end
    # it "logs in with valid user" do
    #   puts @user.email + " " + @user.password
    #   expect(is_logged_in?).to be_truthy
    # end
  end
end

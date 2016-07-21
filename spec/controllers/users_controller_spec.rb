require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "create new user" do
    before :each do
      get :new
      post :create, params: { user: {first_name: "Test",
                                        last_name:  "User",
                                        email:      "user1@example.com",
                                        password:              "foobar",
                                        password_confirmation: "foobar"}}
    end
    it "returns http redirect" do
      expect(response).to have_http_status("302")
    end
    it "displays a flash message" do
      expect(flash[:success]).to be_present
    end
    it "logs in user" do
      expect(is_logged_in?).to be_truthy
    end
  end
end

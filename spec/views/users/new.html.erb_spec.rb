require 'rails_helper'

RSpec.describe "users/new.html.erb", type: :view do
  before :each do
    visit signup_path
  end
  
  describe "Signup layout" do
    it "has the correct page title" do
      expect(page).to have_title("Sign Up | Stearman Analytics")
    end
    
    it "has the correct header" do
      expect(page).to have_content("Sign Up!")
    end
  end
end

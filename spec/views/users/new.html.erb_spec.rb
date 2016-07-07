require 'rails_helper'

RSpec.describe "users/new.html.erb", type: :view do
  
  before :each do
    visit signup_path
  end
  
  describe "Sign up page" do
    it "has the correct title" do
      expect(page).to have_title('Sign Up | Stearman Analytics')
    end
    it "has the correct header" do
      expect(page).to have_content('Sign Up')
    end
  end
end

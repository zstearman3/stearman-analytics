require 'spec_helper'

describe "User signing page" do
  it "doesn't allow signup with invallid information" do
    expect{signup_with("Test", "User", "test@example,com", 
                       "foobar")}.to_not change{ User.count }
  end
  describe "with invalid signup information" do
    before :each do
      signup_with("Test", "User", "test@example,com", "foobar")
    end
    it "renders correct view upon signup failure" do
      expect(page).to have_content("Sign Up!")
    end
    it "shows error explanation" do
      expect(page).to have_css('div#error_explanation')
    end
    it "highlights fields with errors" do
      expect(page).to have_css('div.field_with_errors')
    end
  end
  it "allows a user to signup with valid information" do
    expect{signup_with("Test", "User", "test@example.com", 
                       "foobar")}.to change{ User.count }
  end
  describe "with valid signup information" do
    before :each do
      signup_with("Test", "User", "test@example.com", "foobar")
    end
    it "renders correct view upon valid submission" do
      expect(page).to have_content("Test User")
    end
    it "has the correct title name in user page" do
      expect(page).to have_title("Test User | Stearman Analytics")
    end
  end
end


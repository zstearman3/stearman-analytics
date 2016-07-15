require 'spec_helper'

describe 'Try to login' do
  describe 'with invalid information' do
    before :each do
      login_with('trial@example.com', 'password')
    end
    it 'renders login template again' do
      expect(page).to have_content('Log In!')
    end
    it 'shows a flash message' do
      expect(page).to have_content('Invalid email/password combination')
    end
    it 'only displays flash for one page' do
      visit root_path
      expect(page).to_not have_content('Invalid email/password combination')
    end
  end
  describe 'with valid information' do
    before :each do
      signup_with("Test", "User", "test@example.com", "foobar")
      login_with("test@example.com", "foobar")
    end
    it "should redirect to user profile" do
      expect(page).to have_content("Test User")
    end
    it "should add 'Account' link" do
      expect(page).to have_link("Account")
    end
    it "should not show 'Log In' link" do
      expect(page).to_not have_link("Log In")
    end
  end
end


require 'spec_helper'

describe 'Try to login' do
  before :each do
    @user = create(:user)
  end
  describe 'with invalid information' do
    before :each do
      login_with('invalid@email,com', @user.password)
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
      signup_with(@user.first_name, @user.last_name, @user.email, 'password')
      login_with(@user.email, "password")
    end
    it "should redirect to user profile" do
      expect(page).to have_content(@user.first_name + " " + @user.last_name)
    end
    it "should add 'Account' link" do
      expect(page).to have_link("Account")
    end
    it "should not show 'Log In' link" do
      expect(page).to_not have_link("Log In")
    end
  end
end


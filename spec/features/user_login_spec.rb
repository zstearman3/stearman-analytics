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
end

def login_with(email, password)
  visit login_path
  fill_in 'Email',    with: email
  fill_in 'Password', with: password
  click_button 'Log in'
end
require 'rails_helper'

RSpec.describe "Log In view", type: :view do
  it "has a login button" do
    visit login_path
    expect(page).to have_button "Log in"
  end
end

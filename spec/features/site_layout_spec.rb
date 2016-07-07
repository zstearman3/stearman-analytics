require 'spec_helper'

describe "Navigate around site layout" do
  it "dislpays the correct links on the home page" do
    visit root_path
    expect(page).to have_selector(:link_or_button, 'Sign up now!')
    expect(page).to have_link('Help', :href => help_path)
    expect(page).to have_link('About', :href => about_path)
    expect(page).to have_link('Contact', :href => contact_path)
    expect(page).to have_link(nil, :href => root_url, count: 2)
  end
  
  it "navigates through the links correctly" do
    visit root_path
    click_link('Help')
    expect(page).to have_content('Help Me!')
    visit root_path
    click_link('Contact')
    expect(page).to have_content('Contact Me')
  end
end
require 'rails_helper'

RSpec.describe "static_pages/help.html.erb", type: :view do
  
  before :each do
    visit static_pages_help_path
  end
  
  it "correctly displays the title of each static page" do
    expect(page).to have_title("Help | StearmanAnalytics")
  end
  
  it "displays the 'Help Me' header on the page" do
    expect(page).to have_content("Help Me!")
  end
  
end

require 'rails_helper'

RSpec.describe "static_pages/home.html.erb", type: :view do
  
  before :each do
    visit root_url
  end
  
  it "correctly displays the title of the page" do
    expect(page).to have_title("Home | StearmanAnalytics")
  end
  
  it "shows the website name in the header" do
    expect(page).to have_content("Stearman Analytics")
  end
end

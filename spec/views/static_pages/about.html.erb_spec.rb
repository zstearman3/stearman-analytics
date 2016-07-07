require 'rails_helper'

RSpec.describe "static_pages/about.html.erb", type: :view do
  
  before :each do
    visit about_path
  end
  
  it "correctly displays the title of each static page" do
    expect(page).to have_title("About | Stearman Analytics")
  end
  
end

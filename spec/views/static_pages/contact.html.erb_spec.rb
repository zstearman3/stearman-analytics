require 'rails_helper'

RSpec.describe "static_pages/contact.html.erb", type: :view do
  
  before :each do
    visit static_pages_contact_path
  end
  
  it "correctly displays the title of each static page" do
    expect(page).to have_title("Contact | Stearman Analytics")
  end
  
  it "displays the 'Help Me' header on the page" do
    expect(page).to have_content("Contact")
  end
  
end

require 'rails_helper'

RSpec.describe "teams/index.html.erb", type: :view do
  before :each do
    visit rankings_path
  end
  it "displays a table" do
    expect(page).to have_css('table')
  end
end

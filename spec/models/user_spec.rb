require 'rails_helper'

RSpec.describe User, type: :model do
  
  before :each do
    @user = User.new(name: "Example User", email: "user@example.com")
  end
  
  describe "Set Up User" do
    it "should allow a valid user to be valid." do
      expect(@user.valid?).to be_truthy
    end
    
    it "should not allow name to be empty" do
      @user.name = "       "
      expect(@user.valid?).to be_falsey
    end
  end
end

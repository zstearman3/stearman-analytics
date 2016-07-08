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
    
    it "should not allow email to be empty" do
      @user.email = "      "
      expect(@user.valid?).to be_falsey
    end
    
    it "should not allow name to be too long" do
      @user.name = "a" * 51
      expect(@user.valid?).to be_falsey
    end
    
    it "should not allow email to be too long" do
      @user.email = "a" * 244 + "@example.com"
      expect(@user.valid?).to be_falsey
    end
    
    it "should accept valid email addresses" do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org 
                           first.last@foo.jp alice+bob@baz.cn]
      valid_addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user.valid?).to be_truthy, "#{@user.email} should be valid"
      end
    end
    
    it "should not accept invalid email addresses" do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. 
                             foo@bar_baz.com foo@bar+baz.com]
      invalid_addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user.valid?).to be_falsey, "#{@user.email} should not be valid"
      end
    end
    
    it "should require unique email addresses" do
      duplicate_user = @user.dup
      duplicate_user.email = @user.email.upcase
      @user.save
      expect(duplicate_user.valid?).to be_falsey
    end
  end
end

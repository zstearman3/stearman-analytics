require 'rails_helper'

RSpec.describe User, type: :model do
  
  before :each do
    @user = User.new(first_name: "Example", last_name: "User",
                     email: "user@example.com", password: "foobar", 
                     password_confirmation: "foobar")
  end
  
  describe "Set Up User" do
    it "should allow a valid user to be valid." do
      expect(@user.valid?).to be_truthy
    end
    
    it "should not allow first name to be empty" do
      @user.first_name = "       "
      expect(@user.valid?).to be_falsey
    end
    
    it "should not allow last name to be empty" do
      @user.last_name = "       "
      expect(@user.valid?).to be_falsey
    end
    
    it "should not allow email to be empty" do
      @user.email = "      "
      expect(@user.valid?).to be_falsey
    end
    
    it "should not allow first name to be too long" do
      @user.first_name = "a" * 31
      expect(@user.valid?).to be_falsey
    end
    
    it "should not allow last name to be too long" do
      @user.last_name = "a" * 31
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
    
    it "should save email addresses as lower-case" do
      mixed_case_email = "Foo@ExAMPle.cOM"
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eql(mixed_case_email.downcase)
    end
    
    it "should require a nonblank password" do
      @user.password = @user.password_confirmation = "       "
      expect(@user.valid?).to be_falsey
    end
    
    it "should require password to have minimum length" do
      @user.password = @user.password_confirmation = "a" * 5
      expect(@user.valid?).to be_falsey
    end
    
    it "should require password and confirmation password to match" do
      @user.password = "foobaz"
      expect(@user.valid?).to be_falsey
    end
    
    it "should not authenticate a user with no remember token" do
      expect(@user.authenticated?('')).to be_falsey
    end
    
  end
end

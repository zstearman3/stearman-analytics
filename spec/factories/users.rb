FactoryGirl.define do
  factory :user do
    first_name "Example"
    last_name "User"
    email "example@user.com"
    password 'password'
    password_digest { User.digest('password') }
  end
  
  
end
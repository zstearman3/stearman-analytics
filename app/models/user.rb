class User < ApplicationRecord
  attr_accessor :remember_token
  
  before_save { email.downcase! }
  validates :first_name,  presence:true, length: { maximum: 30 }
  validates :last_name,   presence:true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
  
  def full_name
    return first_name + " " + last_name
  end
  
  class << self
    # Returns the has digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    
    #Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
    
  #Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest) == remember_token
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
end
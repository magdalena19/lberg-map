class User < ActiveRecord::Base
  has_secure_password
  has_many :announcements

  attr_accessor :password_reset_token

  validates :name, presence: true
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, length: { minimum: 5 }, if: :password

  def authenticated?(attribute:, token:)
    return false unless digest = self.send("#{attribute}_digest") 
    BCrypt::Password.new(digest).is_password?(token)
  end

  def create_digest_for(attribute:)
    token = SecureRandom.urlsafe_base64(24)
    cost = Rails.env == "production" ? BCrypt::Engine::MAX_SALT_LENGTH : 4
    digest = BCrypt::Password.create(token, cost: cost)

    self.send("#{attribute}_token=", token)
    self.send("#{attribute}_digest=", digest)
    self.send("#{attribute}_timestamp=", Time.now)
  end

  def password_reset_token_alive?
    return false unless password_reset_timestamp
    (Time.now - password_reset_timestamp)/3600 < 24
  end

  def guest?
    false
  end

  def admin?
    is_admin
  end

  def signed_in?
    true
  end
end

class User < ActiveRecord::Base
  has_secure_password
  has_many :maps, dependent: :nullify
  has_many :activation_tokens, dependent: :destroy
  # TODO legacy?
  has_many :announcements

  before_create :create_activation_tokens, if: 'Admin::Setting.user_activation_tokens > 0'

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

  def registered?
    true
  end

  private

  def create_activation_tokens
    Admin::Setting.user_activation_tokens.times do
      self.activation_tokens << ActivationToken.create
    end
  end
end

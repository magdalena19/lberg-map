class Map < ActiveRecord::Base
  has_many :places

  before_create :generate_secret_token
  before_create :generate_public_token, if: 'is_public'

  private

  def generate_public_token
    self.public_token = SecureRandom.urlsafe_base64(24)
  end

  def generate_secret_token
    self.secret_token = SecureRandom.urlsafe_base64(24)
  end
end

class User < ActiveRecord::Base
  has_secure_password
  has_many :announcements

  validates :name, presence: true
  validates :email, presence: true
  # Validate email format, e.g. do not allow Heidi@googlemail or @gmail.com
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, length: { minimum: 5 }, if: :password
end

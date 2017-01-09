require 'sanitize'

class Announcement < ActiveRecord::Base
  include Sanitization
  belongs_to :user

  validates :header, :content, presence: true
  validates :header, length: { minimum: 5, maximum: 100 }

  before_validation :sanitize_content, on: [:create, :update]

  def sanitize_content
    self.content = sanitize(content)
  end
end

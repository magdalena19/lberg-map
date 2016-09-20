class Announcement < ActiveRecord::Base
  belongs_to :user

  validates :header, :content, presence: true
  validates :header, length: { minimum: 5, maximum: 100 }
end

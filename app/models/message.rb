require 'sanitize'

class Message < ActiveRecord::Base
  include Sanitization

  before_validation :sanitize_message_text, on: [:create]

  validates :sender_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: 'sender_email.present?'
  validates :subject, presence: true
  validates :text, presence: true

  belongs_to :map
  
  def self.tags
    [
      I18n.t('messages.tags.technically_related'),
      I18n.t('messages.tags.content_related'),
      I18n.t('messages.tags.misc_related')
    ]
  end

  private

  # TODO test that
  def sanitize_message_text
    self.text = sanitize(text)
  end
end

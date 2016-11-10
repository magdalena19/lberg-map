class Message < ActiveRecord::Base
	validates :sender_name, presence: true
	validates :sender_email, presence: true
	validates :subject, presence: true
	validates :text, presence: true

	def self.tags
		['Technical question', 'Question related to map content']
	end
end

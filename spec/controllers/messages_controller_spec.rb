require 'rails_helper'

describe MessagesController do
  it 'should enqueue valid message for delivery' do
    map = create :map, :full_public
    message = build :message
    
    Sidekiq::Testing.fake! do
			expect{
        post :create, message: message.attributes, map_token: map.public_token
			}.to change{ MailerWorker.jobs.size }.by(1)
    end
  end
end

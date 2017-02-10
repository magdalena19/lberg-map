require 'rails_helper'

describe MessagesController do
  it 'should enqueue valid message for delivery' do
    message = build :message
    
    Sidekiq::Testing.fake! do
			expect{
				post :create, message: message.attributes
			}.to change{ MailerWorker.jobs.size }.by(1)
      # expect(flash[:success]).not_to be_nil
    end
  end
end

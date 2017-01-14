require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  def setup
    @message = build :message 
  end

  test 'Should queue valid message for delivery' do
    Sidekiq::Testing.fake! do
      assert_difference 'MailerWorker.jobs.size' do
        post :create, message: @message.attributes
      end
      assert flash[:success]
    end
  end
end

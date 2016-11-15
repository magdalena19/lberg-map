require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  test "Should queue valid message for delivery" do
		assert_difference 'DeliveryGul.deliveries.count' do
			post :create, message: {sender_name: 'test',
															sender_email: 'me@you.com',
															subject: 'This is a test request',
															text: 'This is some sample test'}
			assert flash[:success]
		end
  end
end

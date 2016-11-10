require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
		assert_difference 'DeliveryGul.deliveries.count' do
			post :create, message: {sender_name: 'test',
															sender_email: 'me@you.com',
															subject: 'This is a test request',
															text: 'This is some sample test'}
		end
  end
end

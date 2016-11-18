require_relative '../test_helper'

class DeliveryGulTest < ActionMailer::TestCase
  def setup
    @message = Message.new(sender_name: 'Me', sender_email: 'foo@bar.org', subject: 'Test subject', text: 'Test text')
  end

  test "send copy to sender" do
    email = DeliveryGul.send_copy_to_sender(@message).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [AppConfig.general['maintainer_email_address']], email.from
    assert_equal ['foo@bar.org'], email.to
    assert_equal "Copy of your request on #{AppConfig.general['app_title']}", email.subject
  end

  test "send to maintainer" do
    email = DeliveryGul.send_to_maintainer(@message).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [AppConfig.general['maintainer_email_address']], email.from
    assert_equal [AppConfig.general['maintainer_email_address']], email.to
    assert_equal "[#{AppConfig.general['app_title']} contact form] #{@message.subject}", email.subject
  end
end

FactoryGirl.define do
  factory :message do
    sender_name 'test'
    sender_email 'me@you.com'
    subject 'This is a test request'
    text 'This is some sample test'
  end
end

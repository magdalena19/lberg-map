FactoryGirl.define do
  factory :activation_token do
    token { SecureRandom.urlsafe_base64 12 }
  end
end

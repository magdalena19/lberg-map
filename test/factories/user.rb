FactoryGirl.define do
  factory :user do
    name 'User'
    email { name.downcase + "@example.com" }
    password_digest BCrypt::Password.create('secret', cost: 4)

    trait :admin do
      is_admin true
    end
  end
end

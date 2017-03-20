FactoryGirl.define do
  factory :map do
    title 'SomeMap'
    description 'This is some map'
    imprint 'This is some imprint'
    maintainer_email_address 'foo@bar.org'

    trait :public do
      is_public true
    end

    trait :private do
      is_public false
    end
  end
end

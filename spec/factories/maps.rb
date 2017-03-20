FactoryGirl.define do
  factory :map do
    title 'SomeMap'
    description 'This is some map'
    imprint 'This is some imprint'
    maintainer_email_address 'foo@bar.org'

    trait :full_public do
      is_public true
      auto_translate true
      translation_engine 'bing'
      allow_guest_commits false
    end

    trait :restricted_accessc do
      is_public true
      auto_translate true
      translation_engine 'bing'
      allow_guest_commits false
    end

    trait :private do
      is_public false
    end

    trait :top_secret do
      is_public false
      auto_translate false
      allow_guest_commits false
    end
  end
end

FactoryGirl.define do
  factory :settings, class: 'Admin::Setting' do
    app_title 'Title'
    maintainer_email_address 'foo@bar.org'
    translation_engine 'bing'

    trait :public do
      is_private false
    end

    trait :private do
      is_private true
    end

    trait :top_secret do
      is_private true
      auto_translate false
    end
  end
end

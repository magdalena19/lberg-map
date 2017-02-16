FactoryGirl.define do
  factory :settings, class: 'Admin::Setting' do
    app_title 'Title'
    maintainer_email_address 'foo@bar.org'

    trait :private do
      is_private true
    end

    trait :top_secret do
      is_private true
      auto_translate false
    end
  end
end

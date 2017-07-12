FactoryGirl.define do
  factory :map do
    title 'SomeMap'
    description 'This is some map'
    imprint 'This is some imprint'
    maintainer_email_address 'foo@bar.org'
    secret_token { SecureRandom.urlsafe_base64(24) }
    supported_languages I18n.available_locales
    user

    trait :public_guest_map do
      title 'PublicGuestMap'
      is_public true
      auto_translate true
      translation_engine 'bing'
      allow_guest_commits true
      public_token { SecureRandom.urlsafe_base64(24) }
      user nil
    end

    trait :full_public do
      title 'PublicMap'
      is_public true
      auto_translate true
      translation_engine 'bing'
      allow_guest_commits true
      public_token { SecureRandom.urlsafe_base64(24) }
    end

    trait :restricted_access do
      title 'RestrictedAccessMap'
      is_public true
      auto_translate true
      translation_engine 'bing'
      allow_guest_commits false
      public_token { SecureRandom.urlsafe_base64(24) }
    end

    trait :private do
      title 'PrivateMap'
      is_public false
      allow_guest_commits false
    end

    trait :top_secret do
      title 'TopSecretMap'
      is_public false
      auto_translate false
      allow_guest_commits false
    end
  end
end

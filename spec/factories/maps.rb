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
      allow_guest_commits true
      public_token { SecureRandom.urlsafe_base64(24) }
      user nil
    end

    trait :full_public do
      title 'PublicMap'
      is_public true
      allow_guest_commits true
      public_token { SecureRandom.urlsafe_base64(24) }
    end

    trait :restricted_access do
      title 'RestrictedAccessMap'
      is_public true
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
      allow_guest_commits false
    end
    
    # Encrypted with test ENV secret key base 
    trait :autopost_twitter do
      autopost_twitter true
      twitter_access_token 'AE49FBF6B59F99D7813E81440DD03A07'
      twitter_access_token_secret 'AE49FBF6B59F99D7813E81440DD03A07'
      twitter_api_key 'AE49FBF6B59F99D7813E81440DD03A07'
      twitter_api_secret_key 'AE49FBF6B59F99D7813E81440DD03A07'
      twitter_autopost_message "A new place has been inserted"
      twitter_hashtags "#foo #bar"
    end
  end
end

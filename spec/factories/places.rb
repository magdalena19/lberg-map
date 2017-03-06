def set_reviewed_on_translations(place)
  place.translations.each do |translation|
    translation.without_versioning do
      translation.update(reviewed: place.reviewed ? true : false)
    end
  end
end

FactoryGirl.define do
  factory :place do
    house_number '100'
    street 'Foo-street'
    postal_code '13045'
    city 'Berlin'
    latitude 52.5
    longitude 13.45
    email 'foo@bar.com'
    homepage 'https://bar.com'
    phone '03081618254'

    after(:create) { |place| set_reviewed_on_translations(place) }

    trait :reviewed do
      name 'SomeReviewedPlace'
      reviewed 'true'
      description_en 'This is a reviewed point'
      categories '1,2'
    end

    trait :unreviewed do
      name 'SomeUnreviewedPlace'
      reviewed 'false'
      description_en 'This is an unreviewed point'
      categories '1,4,5'
    end

    trait :without_address do
      name 'ToBeGeocoded'
      reviewed 'false'
      description_en 'This is a point without any address'
      categories '1,4,5'
      house_number ''
      street ''
      postal_code ''
      city ''
    end

    trait :without_coordinates do
      name 'ToBeGeocoded'
      reviewed 'false'
      latitude nil
      longitude nil
      description_en 'This is a point without any address'
      categories '1,4,5'
    end

    factory :event do
      event true

      trait :past do
        name 'PastEvent'
        start_date { Date.today - 10 }
        end_date { Date.today - 5 }
      end

      trait :ongoing do
        name 'OngoingEvent'
        start_date { Date.today - 10 }
        end_date { Date.today + 5 }
      end

      trait :future do
        name 'FutureEvent'
        start_date { Date.today + 1 }
        end_date { Date.today + 5 }
      end
    end
  end
end

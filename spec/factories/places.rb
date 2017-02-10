def set_reviewed_on_translations(place)
  place.translations.each do |translation|
    translation.without_versioning do
      translation.update(reviewed: place.reviewed ? true : false)
    end
  end
end

FactoryGirl.define do
  factory :place do
    trait :reviewed do
      name 'SomeReviewedPlace'
      house_number '100'
      street 'Foo-street'
      postal_code '13045'
      city 'Berlin'
      latitude 52.5
      longitude 13.45
      email 'foo@bar.com'
      homepage 'https://bar.com'
      phone '03081618254'
      reviewed 'true'
      description_en 'This is a reviewed point'
      categories '1,2'

      after(:create) { |place| set_reviewed_on_translations(place) }
    end

    trait :unreviewed do
      name 'SomeUnreviewedPlace'
      house_number '200'
      street 'Bar-street'
      postal_code '11045'
      city 'Berlin'
      latitude 52.6
      longitude 13.5
      email 'bar@foo.com'
      homepage 'https://foo.com'
      phone '03081618254'
      reviewed 'false'
      description_en 'This is an unreviewed point'
      categories '1,4,5'

      after(:create) { |place| set_reviewed_on_translations(place) }
    end
  end
end

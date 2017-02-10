FactoryGirl.define do
  factory :announcement do
    header 'SomeAnnouncement'
    content 'SomeContentHere'
    user
  end
end

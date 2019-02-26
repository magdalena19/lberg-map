FactoryGirl.define do
  factory :place_attachment do
    place nil
    image Rack::Test::UploadedFile.new(Rails.root.join('app/assets/images/ratmap_logo.jpg'))
  end
end

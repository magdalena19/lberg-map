FactoryGirl.define do
  factory :settings, class: 'Admin::Setting' do
    app_title 'SomeApp'
    admin_email_address 'admin@secret.com'
  end
end

FactoryGirl.define do
  factory :settings, class: 'Admin::Setting' do
    app_title 'SomeApp'
    admin_email_address 'admin@secret.com'
    user_activation_tokens 2
    app_imprint ''
    app_privacy_policy ''
    captcha_system 'recaptcha'
    default_poi_color Place.available_colors.first
    multi_color_pois true
  end
end

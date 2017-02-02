require_relative '../test_helper'

feature 'Sidekiq dashboard' do
  scenario 'Dashboard cannot be reached as guest user' do
    assert_raise ActionController::RoutingError do
      visit sidekiq_web_path
    end
  end

  scenario 'Dashboard cannot be reached as regular user' do
    login_as_user

    assert_raise ActionController::RoutingError do
      visit sidekiq_web_path
    end
  end

  scenario 'Dashboard can be reached as admin' do
    login_as_admin
    assert_nothing_raised do
      visit sidekiq_web_path
    end
  end
end

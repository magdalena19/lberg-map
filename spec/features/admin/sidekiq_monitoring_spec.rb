feature 'Sidekiq dashboard' do
  scenario 'Dashboard cannot be reached as guest user' do
    skip("Test not working, wait for expert feedback")
    expect {
      visit sidekiq_web_path
    }.to raise_error(ActionController::RoutingError)
  end

  scenario 'Dashboard cannot be reached as regular user' do
    skip("Test not working, wait for expert feedback")
    login_as_user

    expect {
      visit sidekiq_web_path
    }.to raise_error(ActionController::RoutingError)
  end

  scenario 'Dashboard can be reached as admin' do
    skip("Test not working, wait for expert feedback")
    login_as_admin

    expect {
      visit sidekiq_web_path
    }.to_not raise_error(ActionController::RoutingError)
  end
end

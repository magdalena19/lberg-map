feature 'Map', js: true do
  scenario 'can set password protection for map' do
    visit new_map_path
    fill_in 'map_title', with: 'SomeTitle'
    set_map_pasword(password: 'secret')
    create_map
    protected_map = Map.find_by(title: 'SomeTitle')

    Capybara.reset_sessions!
    visit edit_map_path(map_token: protected_map.secret_token)

    expect(page).to have_css('.password-input')
  end

  private

  def set_map_pasword(password:)
    checkbox = find('.password_input').find_all('input').first
    checkbox.trigger('click') unless checkbox.checked?
    fill_in 'map_password', with: password
    fill_in 'map_password_confirmation', with: password
  end
end

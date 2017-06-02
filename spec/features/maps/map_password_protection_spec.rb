feature 'Map', js: true do
  before do
    login_as_user
  end

  scenario 'can set password protection for map' do
    visit new_map_path
    fill_in 'map_title', with: 'SomeTitle'
    checkbox = find('.password_input').find_all('input').first
    checkbox.trigger('click') unless checkbox.checked?
    fill_in 'map_password', with: 'secret'
    fill_in 'map_password_confirmation', with: 'secret'
    click_on 'Create Map'

    map = Map.find_by(title: 'SomeTitle')
    expect(map.password_protected?).to be true
  end

  scenario 'can unset password protection' do
    skip 'Map rendering issue'

    prot_map = create :map, :full_public, password: 'secret', password_confirmation: 'secret'
    visit edit_map_path(map_token: prot_map.secret_token)
    binding.pry 
    checkbox.trigger('click') if checkbox.checked?
    click_on 'Create Map'

    expect(prot_map.password_protected?).to be false
  end
end

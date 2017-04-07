feature 'Create Map', js: true do
  context 'Secret Map' do
    scenario 'as registered user' do
      login_as_user
      visit new_map_path
      fill_in_valid_map_attributes
      click_on('Create Map')
      map = Map.find_by(secret_token: 'secret_token')

      expect(map).to be_a(Map)
      expect(map.is_public).to be false
      expect(map.user).to eq User.first
    end

    scenario 'as guest user' do
      visit new_map_path
      fill_in_valid_map_attributes
      validate_captcha
      click_on('Create Map')
      map = Map.find_by(secret_token: 'secret_token')

      expect(map).to be_a(Map)
      expect(map.is_public).to be false
      expect(map.user).to be_nil
    end
  end

  context 'Public Map' do
    scenario 'as guest user' do
      visit new_map_path
      fill_in_valid_map_attributes
      click_on('Privacy')
      page.find('#map_is_public').trigger('click')
      fill_in('map_maintainer_email_address', with: 'foo@bar.com')
      fill_in('map_public_token', with: 'public_token')
      click_on('Properties')
      validate_captcha
      click_on('Create Map')
      map = Map.find_by(public_token: 'public_token')

      expect(map).to be_a(Map)
      expect(map.is_public).to be true
      expect(map.user).to be_nil
    end
  end

  private

  def fill_in_valid_map_attributes
    fill_in('map_title', with: 'SomeTitle')
    fill_in('map_secret_token', with: 'secret_token')
  end
end

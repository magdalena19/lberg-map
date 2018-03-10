feature 'Map form', js: true do
  context 'Map creation' do
    before do
      execute_script("jQuery('.footer').css('display', 'none')") # circumvent button finding prob
      visit new_map_path
    end

    scenario 'Check form features' do
      # SPEC INTERFACE
      # Base setup
      click_on('Base setup')
      fill_in_valid_map_attributes

      # Publication settings
      click_on('Publication settings')
      set_as_public
      find('#map_public_token')
      find('#map_maintainer_email_address')
      find('label', text: 'Map imprint (optional)')
      find('#map_allow_guest_commits')

      # Language support
      click_on('Multi-language support')
      find("#map_supported_languages_[value='de']").set(true)
      find("#map_supported_languages_[value='en']").set(false)

      create_map
      map = Map.find_by(secret_token: 'secret_token')

      expect(map.supported_languages).to eq ['de']
      expect(map).to be_a(Map)
      expect(map.is_public).to be true
      expect(map.user).to eq User.first
    end
  end

  private

  # Map form helpers
  def fill_in_valid_map_attributes
    fill_in('map_title', with: 'SomeTitle')
    fill_in('map_secret_token', with: 'secret_token')
  end

  def set_as_public
    publish_checkbox.trigger('click') unless publish_checkbox.checked?
  end

  def publish_checkbox
    find('#map_is_public')
  end
end

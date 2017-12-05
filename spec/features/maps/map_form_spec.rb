feature 'Map form', js: true do
  context 'Translation engines' do
    before do
      enable_all_translation_engines
    end

    scenario 'Selection list has correct translation engine value when editing existing map' do
      map = create :map, :full_public, translation_engine: 'google', auto_translate: true
      visit edit_map_path(map_token: map.secret_token)
      click_on('Multi-language support')
      translation_engine = page.find('#map_translation_engine', visible: false).value

      expect(translation_engine).to eq 'google'
    end

    scenario 'Selection list shows no translation engine if none selected when editing existing map' do
      map = create :map, :full_public, translation_engine: 'none', auto_translate: false
      visit edit_map_path(map_token: map.secret_token)
      click_on('Multi-language support')
      translation_engine = page.find('#map_translation_engine', visible: false).value

      expect(translation_engine).to eq 'none'
    end

    scenario 'Selection list shows none by default if translation engine is not set at all' do
      map = create :map, :full_public, translation_engine: '', auto_translate: false
      visit edit_map_path(map_token: map.secret_token)
      click_on('Multi-language support')
      translation_engine = page.find('#map_translation_engine', visible: false).value

      expect(translation_engine).to eq 'none'
    end
  end

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

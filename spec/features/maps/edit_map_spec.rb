feature 'Edit Map', js: true do
  feature 'Automatic translation' do
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

  feature 'Tagging maintainance' do
    scenario 'Can edit tags if any' do
      map = create :map, :full_public, translation_engine: '', auto_translate: false
      place = create :place, map: Map.first, name: 'Jojojo', categories_string: 'Hustla'

      visit edit_map_path(map_token: map.secret_token)
      click_on 'Tags'

      expect(page).to have_field('name', with: 'Hustla')
    end
  end
end

feature 'Edit Map', js: true do
  scenario 'Selection list has correct translation engine value when editing existing map' do
    enable_all_translation_engines
    map = create :map, :full_public, translation_engine: 'google', auto_translate: true
    visit edit_map_path(map_token: map.secret_token)
    click_on('Multi-language support')
    translation_engine = page.find('#map_translation_engine', visible: false).value

    expect(translation_engine).to eq 'google'
  end

  scenario 'Selection list shows no translation engine if none selected when editing existing map' do
    enable_all_translation_engines
    map = create :map, :full_public, translation_engine: 'none', auto_translate: false
    visit edit_map_path(map_token: map.secret_token)
    click_on('Multi-language support')
    translation_engine = page.find('#map_translation_engine', visible: false).value

    expect(translation_engine).to eq 'none'
  end

  scenario 'Selection list shows none by default if auto_translate is false' do
    enable_all_translation_engines
    map = create :map, :full_public, translation_engine: '', auto_translate: false
    visit edit_map_path(map_token: map.secret_token)
    click_on('Multi-language support')
    translation_engine = page.find('#map_translation_engine', visible: false).value

    expect(translation_engine).to eq 'none'
  end
end

feature 'Create Map', js: true do
  scenario 'Can only select map languages supported' do
    map = create :map, :full_public, supported_languages: ['en']
    visit map_path(map_token: map.public_token)
    find('.personal-settings-dropdown').trigger('click')

    expect(page).to have_css('.dropdown-menu li', text: 'en')
    expect(page).not_to have_css('.dropdown-menu li', text: 'de')
  end


  private

  def fill_in_valid_map_attributes
    fill_in('map_title', with: 'SomeTitle')
    fill_in('map_secret_token', with: 'secret_token')
  end
end

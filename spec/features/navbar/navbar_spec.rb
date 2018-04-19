feature 'Navbar', :js do
  scenario 'Link to map settings in Navbar' do
    setup_new_map
    display_correct_logo
    link_to_map_settings
  end

  private

  def setup_new_map
    visit new_map_path
    map_token = SecureRandom.hex
    find('#map_secret_token').set(map_token)
    find('#map_title').set('Two words')
    create_map
    visit map_path(map_token: map_token)
  end

  def display_correct_logo
    expect(page).to have_css('.navbar-logo-green', text: 'Two')
    expect(page).to have_css('.navbar-logo-lilac', text: 'words')
  end

  def link_to_map_settings
    find('.fa-map-o').trigger('click')
    expect(page).to have_content('Map settings')
  end
end

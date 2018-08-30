feature 'Navbar', :js do
  let(:map) { create :map, title: 'Two words' }

  scenario 'Link to map settings in Navbar' do
    visit map_path(map_token: map.secret_token)
    display_correct_logo
    link_to_map_settings
  end

  private

  def display_correct_logo
    expect(page).to have_css('.navbar-logo-green', text: 'Two')
    expect(page).to have_css('.navbar-logo-lilac', text: 'words')
  end

  def link_to_map_settings
    find('.fa-map-o').trigger('click')
    expect(page).to have_content('Map settings')
  end
end

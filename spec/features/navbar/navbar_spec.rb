feature 'Navbar', :js do
  scenario 'Link to map settings in Navbar' do
    map = create :map, :full_public
    visit map_path(map_token: map.secret_token)

    within('#navbar') do
      expect(page).to have_css('.glyphicon-pencil')
    end
  end
end

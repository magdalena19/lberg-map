feature 'Index maps', js: true do
  before do
    login_as_user
  end

  scenario 'foo' do
    display_text_if_no_map_created_yet
    display_maps_list_as_signed_in_user
  end

  private

  def display_text_if_no_map_created_yet
    visit maps_path
    expect(page).to have_content('You have not created any maps yet...')
  end

  def display_maps_list_as_signed_in_user
    create_list(:map, 3, :full_public, user: User.first) 
    visit maps_path

    expect(page).to have_css('.map-panel', count: 3)
  end
end

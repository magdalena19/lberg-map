feature 'Edit place', js: true do
  before do
    @map = create :map, :full_public
    @place = create :place, :reviewed, categories_string: 'Café, Playground', map: @map
  end

  scenario 'Do valid place update as user and show in index afterwards', :js do
    login_as_user
    visit edit_place_path(id: @place.id, map_token: @map.public_token)

    fill_in('place_name', with: 'Any place')
    fill_in('place_postal_code', with: '10963')
    click_on('Update Place')
    show_places_list_panel
    find(:css, '.name').trigger('click')

    expect(page).to have_content('Any place')
    expect(page).to have_content('10963 Berlin')
  end

  scenario 'Do valid place update as guest and do not show changes within other users session', :js do
    skip "Grrrr"

    visit edit_place_path(id: @place.id, map_token: @map.public_token)

    fill_in('place_name', with: 'SomeOtherName')
    click_on('Update Place')
    Capybara.reset_sessions!
    visit map_path(map_token: @map.public_token)
    show_places_list_panel

    expect(page).not_to have_content('SomeOtherName')
    expect(page).to have_css('SomeReviewedPlace')
  end

  scenario 'Display category names in edit field', :js do
    visit edit_place_path(id: @place.id, map_token: @map.public_token)

    expect(page.find('#place_categories_string').value).to eq 'Café, Playground'
  end
end

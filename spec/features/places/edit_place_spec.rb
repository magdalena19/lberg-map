feature 'Edit place' do
  before do
    @map = create :map, :full_public
    @place = create :place, :reviewed, categories: 'Playground, Café', map: @map
  end

  scenario 'Do valid place update as user and show in index afterwards', :js do
    skip 'Map rendering issues'
    login_as_user
    visit edit_place_path(id: @place.id, map_token: @map.public_token)

    fill_in('place_name', with: 'Any place')
    fill_in('place_postal_code', with: '10963')
    click_on('Update Place')
    show_places_index(map_token: @map.public_token)
    expect(page).to have_content('Any place')
    expect(page).to have_content('10963 Berlin')
  end

  scenario 'Do valid place update as guest and show in index afterwards as to be reviewed', :js do
    skip 'Map rendering issues'
    visit edit_place_path(id: @place.id, map_token: @map.public_token)
    fill_in('place_name', with: 'Some changes')
    validate_captcha
    click_on('Update Place')
    show_places_index(map_token: @map.public_token)

    expect(page).to have_content('Some changes')
    expect(page).to have_css('.glyphicon-eye-open')
  end

  scenario 'Do valid place update as guest and do not show changes within other users session', :js do
    skip 'Map rendering issues'
    visit edit_place_path(id: @place.id, map_token: @map.public_token)
    fill_in('place_name', with: 'SomeOtherName')
    validate_captcha
    click_on('Update Place')

    Capybara.reset_sessions!

    show_places_index(map_token: @map.public_token)
    expect(page).not_to have_content('SomeOtherName')
    expect(page).to have_content('SomeReviewedPlace')
    expect(page).not_to have_css('.glyphicon-eye-open')
  end

  scenario 'Display category names in edit field', :js do
    visit edit_place_path(id: @place.id, map_token: @map.public_token)
    expect(page.find('#place_categories').value).to eq 'Café, Playground'
  end
end

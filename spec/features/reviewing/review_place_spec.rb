feature 'Review place' do
  before do
    @map = create :map, :full_public
    @place = create :place, :reviewed, map: @map
  end

  scenario 'Do not show user edits in review index', :js do
    login_as_user
    visit edit_place_path id: @place.id, map_token: @map.secret_token
    fill_in('place_name', with: 'USER CHANGE')
    click_on('Update Place')
    visit places_review_index_path(map_token: @map.secret_token)

    expect(page).not_to have_content('USER CHANGE')
  end

  scenario 'Show guest edits in review index and review place', :js do
    visit edit_place_path id: @place.id, map_token: @map.public_token
    fill_in('place_name', with: 'GUEST CHANGE')
    
    click_on('Update Place')
    login_as_user
    visit places_review_index_path(map_token: @map.secret_token)

    expect(page).to have_content('SomeReviewedPlace')

    visit review_place_path id: @place.id, map_token: @map.secret_token

    expect(page).to have_content('SomeReviewedPlace')
    expect(page).to have_content('GUEST CHANGE')
  end
end

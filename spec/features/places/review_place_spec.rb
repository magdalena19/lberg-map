feature 'Review place' do
  before do
    create :settings, :public
    spawn_categories
  end

  scenario 'Do not show user edits in review index', :js do
    place = create :place, :reviewed
    login_as_user
    visit edit_place_path id: place.id
    fill_in('place_name', with: 'USER CHANGE')
    click_on('Update Place')
    visit '/places/review_index'
    expect(page).not_to have_content('USER CHANGE')
  end

  scenario 'Show guest edits in review index and review place', :js do
    place = create :place, :reviewed
    visit edit_place_path id: place.id
    fill_in('place_name', with: 'GUEST CHANGE')
    validate_captcha
    click_on('Update Place')
    login_as_user
    visit places_review_index_path
    expect(page).to have_content('SomeReviewedPlace')

    visit review_place_path id: place.id
    expect(page).to have_content('SomeReviewedPlace')
    expect(page).to have_content('GUEST CHANGE')
  end
end

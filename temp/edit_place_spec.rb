RSpec.feature 'Edit place', type: feature do
  let(:place) { create :place, :reviewed }

  before do
    spawn_categories
  end

  scenario 'Do valid place update as user and show in index afterwards', :js do
    login_as_user
    visit edit_place_path(id: place.id)

    fill_in('place_name', with: 'Any place')
    fill_in('place_postal_code', with: '10963')
    click_on('Update Place')
    visit '/places'
    binding.pry
    expect(page).to have_content('Any place')
    expect(page).to have_content('10963 Berlin')
  end

  scenario 'Do not create new version when nothing is changed in form', :js do
    visit edit_place_path(id: place.id)
    validate_captcha
    click_on('Update Place')
    expect(Place.find(place.id).versions.length).to be 1
  end

  scenario 'Do valid place update as guest and show in index afterwards as to be reviewed', :js do
    visit edit_place_path(id: place.id)
    fill_in('place_name', with: 'Some changes')
    validate_captcha
    click_on('Update Place')
    visit '/places'

    expect(page).to have_content('Some changes')
    expect(page).to have_css('.glyphicon-eye-open')
  end

  scenario 'Do valid place update as guest and do not show changes within other users session', :js do
    visit edit_place_path(id: place.id)
    fill_in('place_name', with: 'SomeOtherName')
    validate_captcha
    click_on('Update Place')

    Capybara.reset_sessions!
    visit '/places'
    expect(page).not_to have_content('SomeOtherName')
    expect(page).to have_content('SomeReviewedPlace')
    expect(page).not_to have_css('.glyphicon-eye-open')
  end
end

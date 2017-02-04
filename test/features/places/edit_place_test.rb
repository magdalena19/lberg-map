require_relative '../../test_helper'

feature 'Edit place' do
  before do
    @place = create(:place, :reviewed)
  end

  scenario 'Do valid place update as user and show in index afterwards', :js do
    login_as_user
    visit edit_place_path id: @place.id

    fill_in('place_name', with: 'Any place')
    fill_in('place_postal_code', with: '10963')
    click_on('Update Place')
    visit '/places'

    page.must_have_content('Any place')
    page.must_have_content('10963 Berlin')
  end

  scenario 'Do not create new version when nothing is changed in form', :js do
    visit edit_place_path id: @place.id
    validate_captcha
    click_on('Update Place')
    assert_equal 1, Place.find(@place.id).versions.length
  end

  scenario 'Do valid place update as guest and show in index afterwards as to be reviewed', :js do
    visit edit_place_path id: @place.id
    fill_in('place_name', with: 'Some changes')
    validate_captcha
    click_on('Update Place')
    visit '/places'

    page.must_have_content('Some changes')
    page.must_have_css('.glyphicon-eye-open')
  end

  scenario 'Do valid place update as guest and do not show changes within other users session', :js do
    visit edit_place_path id: @place.id
    fill_in('place_name', with: 'SomeOtherName')
    validate_captcha
    click_on('Update Place')

    Capybara.reset_sessions!
    visit '/places'
    page.wont_have_content('SomeOtherName')
    page.must_have_content('SomeReviewedPlace')
    page.wont_have_css('.glyphicon-eye-open')
  end
end

feature 'Create event', :js do
  before do
    map = create :map, :full_public, maintainer_email_address: 'foo@bar.org'
    visit new_place_path(map_token: map.public_token)
  end

  scenario 'can check place to be an event' do
    expect(page).to have_css('#is_event')
  end

  scenario 'event flag is false by default' do
    skip('User agent does not display aria describedby very well...')

    expect(page.find('#is_event')).not_to be_checked
    expect(page).to_not have_css('#place_start_date')
    expect(page).to_not have_css('#set_end_date')
  end

  scenario 'can enter dates if place is flagged as event' do
    page.find('#is_event').trigger('click')
    
    expect(page).to have_css('#place_start_date')
  end

  scenario 'can set single date' do
    fill_in_valid_place_information
    page.find('#is_event').trigger('click')

    expect(page).to have_css('#set_end_date')
  end

  scenario 'unchecking end date shows single date picker' do
    skip 'Works live...'
    fill_in_valid_place_information
    fill_in_valid_place_information
    page.find('#is_event').trigger('click')
    page.find('#place_start_date').trigger('click')

    expect(page).to have_css('.left')
    expect(page).not_to have_css('.right')
  end

  scenario 'checking end date shows date range picker' do
    fill_in_valid_place_information
    page.find('#is_event').trigger('click')
    page.find('#set_end_date').trigger('click')
    page.find('#place_start_date').trigger('click')
    
    expect(page).to have_css('.left')
    expect(page).to have_css('.right')
  end

  scenario 'can create event with only single date' do
    fill_in_valid_place_information
    page.find('#is_event').trigger('click')
    page.find('#place_start_date').trigger('click')
    fill_in('place_start_date', with: '21.04.2017 12:00 AM')
    validate_captcha
    click_button('Create Place')
    new_place = Place.last

    expect(new_place.start_date).to be_a(Time)
    expect(new_place.end_date).to be_nil
  end

  scenario 'can create event with date range' do
    fill_in_valid_place_information
    page.find('#is_event').trigger('click')
    page.find('#place_start_date').trigger('click')
    fill_in('place_start_date', with: '21.04.2017 12:00 AM - 01.06.2017 11:00 PM')
    validate_captcha
    click_button('Create Place')
    new_place = Place.last

    expect(new_place.start_date).to be_a(Time)
    expect(new_place.end_date).to be_a(Time)
  end
end

feature 'Create event' do
  before do
    map = create :map, :full_public, maintainer_email_address: 'foo@bar.org'
    visit new_place_path(map_token: map.public_token)
  end

  scenario 'can check place to be an event', js: true do
    expect(page).to have_css('#place_event')
  end

  scenario 'event flag is false by default', js: true do
    expect(page.find('#place_event')).not_to be_checked
    expect(page).to_not have_css('#place_start_date')
    expect(page).to_not have_css('#set_end_date')
  end

  scenario 'can enter dates if place is flagged as event', js: true do
    page.find('#place_event').trigger('click')
    expect(page).to have_css('#place_start_date')
  end

  scenario 'can set single date', :js do
    fill_in_valid_place_information
    page.find('#place_event').trigger('click')
    expect(page).to have_css('#set_end_date')
  end

  scenario 'unchecking end date shows single date picker', :js do
    skip('Problem with day of date when testing at specific dates of month itself, weird...')
    fill_in_valid_place_information
    fill_in_valid_place_information
    page.find('#place_event').trigger('click')
    expect(page.find('#set_end_date')).not_to be_checked
    page.find('#place_start_date').trigger('click')
    expect(page).to have_css('.single')
    within('.left') { find('td', text: '23').trigger('click')  }
    click_on('Apply')
    validate_captcha
    click_button('Create Place')

    new_place = Place.last
    expect(new_place.start_date).to be_a(Time)
    expect(new_place.end_date).to be_nil
  end
  
  scenario 'checking end date shows date range picker', :js do
    skip('Works live, dunno why not here...')
    fill_in_valid_place_information
    page.find('#place_event').trigger('click')
    page.find('#set_end_date').trigger('click')
    page.find('#place_start_date').trigger('click')
    within('.left') { find('td', text: '15').trigger('click')  }
    within('.right') { find('td', text: '21').trigger('click') }
    validate_captcha
    click_button('Create Place')

    new_place = Place.last
    expect(new_place.start_date).to be_a(Time)
    expect(new_place.end_date).to be_a(Time)
  end
end

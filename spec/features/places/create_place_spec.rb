feature 'Create place' do
  before do
    create :settings, :public
  end

  scenario 'create valid place as user', js: true do
    login_as_user
    visit new_place_path
    fill_in_valid_place_information
    click_button('Create Place')
    visit places_path

    expect(page).to have_content('Any place', count: 1)
  end

  scenario 'create valid place as guest', js: true do
    create_place_as_guest('Another place')
    visit places_path

    expect(page).to have_content('Another place')
    expect(page).not_to have_css('.glyphicon-pencil')
  end

  scenario 'should create new categories if not existent already', js: true do
    expect(Category.count).to eq 0
    login_as_user
    visit new_place_path
    fill_in_valid_place_information
    fill_in('place_categories', with: 'Hospital, Cafe')
    click_button('Create Place')

    expect(Category.count).to eq 2
    expect(Place.last.categories).to eq '1,2'
  end

  scenario 'see guests session places on map', js: true do
    create_place_as_guest('Another place')
    create_place_as_guest('Still another place')
    visit '/en'

    expect(page).to have_content('Another place')
    expect(page).to have_content('Still another place')
  end

  scenario 'visit new place view with coordinate parameters', js: true do
    visit '/places/new?longitude=1&latitude=1' # coordinate values do not matter, because response is mocked

    expect(find_field('place_city').value).to eq('Berlin')
  end

  scenario 'show only one wysiwyg editor for current locale', js: true do
    visit new_place_path
    expect(page).to have_css('.wysihtml5-toolbar', count: 1)

    page.find('.glyphicon-triangle-bottom').trigger('click')
    expect(page).to have_css('.wysihtml5-toolbar', count: 2)
  end

  scenario 'Reverse geocodes if lat/lon is provided and populates value to form fields', js: true do
    visit 'en/places/new?longitude=12&latitude=52'

    expect(page.find('#place_street').value).to eq('Magdalenenstraße')
    expect(page.find('#place_postal_code').value).to eq('10365')
    expect(page.find('#place_city').value).to eq('Berlin')
  end

  scenario 'Commits hidden geofeatures district, federal state and country', js: true do
    visit 'en/places/new?longitude=12&latitude=52'

    fill_in('place_name', with: 'SomePlace')
    validate_captcha
    click_on('Create Place')
    new_place = Place.find_by(name: 'SomePlace')

    expect(new_place.district).to eq 'Lichtenberg'
    expect(new_place.federal_state).to eq 'Berlin'
    expect(new_place.country).to eq 'Germany'
  end

  def create_place_as_guest(place_name)
    visit new_place_path
    fill_in_valid_place_information
    fill_in('place_name', with: place_name)
    validate_captcha
    click_on('Create Place')
  end

  def fill_in_valid_place_information
    fill_in('place_name', with: 'Any place')
    fill_in('place_street', with: 'Magdalenenstr.')
    fill_in('place_house_number', with: '19')
    fill_in('place_postal_code', with: '10963')
    fill_in('place_city', with: 'Berlin')
    fill_in('place_email', with: 'schnipp@schnapp.com')
    fill_in('place_homepage', with: 'http://schnapp.com')
    fill_in('place_phone', with: '03081763253')
    fill_in('place_categories', with: 'Hospital, Cafe')
  end
end

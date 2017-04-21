module CapybaraHelpers
  def validate_captcha
    fill_in 'captcha', with: SimpleCaptcha::SimpleCaptchaData.first.value
  end

  def login_as_user
    user = create :user, email: 'user@example.com', password: 'secret', password_confirmation: 'secret'
    visit 'login/'
    fill_in 'sessions_email', with: user.email
    fill_in 'sessions_password', with: 'secret'
    click_on 'Login'
  end

  def login_as_admin
    admin = create :user, :admin, name: 'Admin', email: 'admin@example.com', password: 'secret', password_confirmation: 'secret'
    visit login_path
    fill_in 'sessions_email', with: admin.email
    fill_in 'sessions_password', with: 'secret'
    click_on 'Login'
  end

  def create_place_as_user(place_name: 'SomePlace', map_token:)
    login_as_user
    visit new_place_path(map_token: map_token)
    fill_in_valid_place_information
    fill_in('place_name', with: place_name)
    find(:css, '.submit-place-button').trigger('click')
  end

  def create_place_as_guest(place_name: 'SomePlace', map_token:)
    visit new_place_path(map_token: map_token)
    fill_in_valid_place_information
    fill_in('place_name', with: place_name)
    validate_captcha
    find(:css, '.submit-place-button').trigger('click')
  end

  def fill_in_valid_place_information
    fill_in('place_name', with: 'Any place')
    fill_in('place_street', with: 'Magdalenenstr.')
    fill_in('place_house_number', with: '19')
    fill_in('place_postal_code', with: '10963')
    fill_in('place_city', with: 'Berlin')
    find(:css, '.contact-information-header').trigger('click')
    fill_in('place_email', with: 'schnipp@schnapp.com')
    fill_in('place_homepage', with: 'http://schnapp.com')
    fill_in('place_phone', with: '03081763253')
    fill_in('place_categories', with: 'Hospital, Cafe')
  end

  def fill_in_valid_date_information
    find(:css, '.date-information-header').trigger('click')
    page.find('#place_event').trigger('click')
    fill_in('place_start_date_date', with: '01.01.2017')
    fill_in('place_start_date_time', with: '01:00')
    fill_in('place_end_date_date', with: '01.01.2018')
    fill_in('place_end_date_time', with: '23:00')
  end
end

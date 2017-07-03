module CapybaraHelpers
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
    fill_in('place_categories_string', with: 'Hospital, Cafe')
  end

  def fill_in_valid_date_information
    find(:css, '.date-information-header').trigger('click')
    page.find('#place_event').trigger('click')
    fill_in('place_start_date_date', with: '01.01.2017')
    fill_in('place_start_date_time', with: '01:00')
    fill_in('place_end_date_date', with: '01.01.2018')
    fill_in('place_end_date_time', with: '23:00')
  end

  def show_places_index
    show_map_controls
    find(:css, '.show-places-index').trigger('click')
  end

  # RIGHT SIDEBAR ACTIONS
  def show_map_controls
    page.find('.toggle-panel').trigger('click') unless page.has_css?('.map-controls-container')
  end

  def show_display_options
    show_map_controls
    find(:css, '.toggle-display-options').trigger('click')
  end

  def show_places_list_panel
    page.find('.toggle-panel').trigger('click') if page.has_css?('.map-controls-container')
  end

  def show_places_index
    show_map_controls
    page.find('.show-places-index').trigger('click')
  end

  def show_events
    show_display_options
    switch = find('.show-events-toggle', visible: false)
    switch.trigger('click') unless switch.checked?
  end
  
  def hide_events
    show_display_options
    switch = find('.show-events-toggle', visible: false)
    switch.trigger('click') if switch.checked?
  end
  
  def show_places
    show_display_options
    switch = find('.show-places-toggle', visible: false)
    switch.trigger('click') unless switch.checked?
  end
  
  def hide_places
    show_display_options
    switch = find('.show-places-toggle', visible: false)
    switch.trigger('click') if switch.checked?
  end
end

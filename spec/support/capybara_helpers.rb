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

  # PLACE CREATION HELPERS
  def create_place_as_user(map_token:, name: 'Any place')
    login_as_user
    create_place(map_token: map_token, name: name)
  end

  def open_new_place_modal(map_token:)
    visit map_path(map_token: map_token)
    find(:css, '.add-place-button').trigger('click')
    within('.create-place-methods-tray') do
      find('.add-place-manually').trigger('click')
    end
    expect(page).to have_css '.modal-dialog'
  end

  def create_place(map_token:, name: 'Any place')
    visit map_path(map_token: @map.secret_token)
    find(:css, '.add-place-button').trigger('click')
    find(:css, '.add-place-manually').trigger('click')
    fill_in_valid_place_information(name: name)
    find(:css, '.submit-place-button').trigger('click')
  end

  def open_edit_place_modal(id:)
    find("div.edit-place[place_id='#{id}']", visible: false).trigger('click') #Find correct edit button
  end

  def update_place_name(map_token:, id:, name:)
    visit map_path(map_token: map_token)
    open_edit_place_modal(id: id)
    fill_in('place_name', with: name)
    click_on('Update Place')
  end

  def fill_in_valid_place_information(name: 'Any place')
    fill_in('place_name', with: name)
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

  # MAP FORM HELPERS
  def create_map
    click_on('Create Map')
    find('.alert', text: 'Map successfully created!')
  end

  def update_map
    click_on('Update Map')
    find('.alert', text: 'Changes saved!')
  end

  # PLACES LIST PANEL ACTIONS
  def show_places_list_panel
    page.find('.toggle-panel').trigger('click')
  end

  def show_place_details(name:)
    show_places_list_panel
    find('div.name', text: name).trigger('click')
  end

  def delete_place(name:)
    show_place_details(name: name)
    page.accept_confirm do
      find('.delete-place').trigger('click')
    end
  end

  # RIGHT SIDEBAR ACTIONS
  def show_map_controls
    page.find('.toggle-panel').trigger('click') unless page.has_css?('.map-controls-container')
  end

  def show_display_options
    show_map_controls
    find(:css, '.toggle-display-options').trigger('click')
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

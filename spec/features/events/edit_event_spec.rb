feature 'Edit event', :js do
  scenario 'event checkbox is checked when place is event' do
    map = create(:map, :full_public)
    event = create(:event, :reviewed,
      name: 'PartySafari',
      categories_string: 'Party',
      start_date: DateTime.new(2015,7,1,20,0),
      end_date: DateTime.new(2015,7,2,12,0),
      phone: 110,
      map: map)

    visit map_path(map_token: map.secret_token)
    fill_in('search-date-input', with: '01.06.2015 20:00 - 05.07.2015 12:00')
    click_on 'Apply'
    open_edit_place_modal(id: event.id)
    page.find(:css, '.date-information-header').trigger('click')

    expect(page.find('#is_event')).to be_checked
  end
end

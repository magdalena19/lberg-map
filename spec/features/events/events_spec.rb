feature 'Create event', :js do
  before do
    Capybara.page.driver.browser.resize(1200, 1200)
    create_map
    open_new_place_modal(map_token: @map.secret_token)
    fill_in_valid_place_information
    show_date_information
    toggle_event_flag
  end

  scenario 'Can enter single date' do
    set_date(position: 'left', day: '15', month: '0', year: '2017')
    click_on('Apply')
    create_place

    new_place = Place.first
    expect(new_place.event).to be true
    expect(new_place.start_date).to eq 'Sun, 15 Jan 2017 00:00:00 UTC +00:00'
  end

  scenario 'Can enter date range' do
    toggle_end_date
    set_date(position: 'left', day: '15', month: '0', year: '2017')
    set_date(position: 'right', day: '15', month: '1', year: '2017')
    click_on('Apply')
    create_place

    new_place = Place.first
    expect(new_place.event).to be true
    expect(new_place.start_date).to eq 'Sun, 15 Jan 2017 00:00:00 UTC +00:00'
    expect(new_place.end_date).to eq 'Wed, 15 Feb 2017 00:00:00 UTC +00:00'
  end

  scenario 'event checkbox is checked when place is event' do
    event = create(:event, :reviewed,
      name: 'PartySafari',
      categories_string: 'Party',
      start_date: DateTime.new(2015,7,1,20,0),
      end_date: DateTime.new(2015,7,2,12,0),
      phone: 110,
      map: @map)

    visit map_path(map_token: @map.secret_token)
    fill_in('search-date-input', with: '01.06.2015 20:00 - 05.07.2015 12:00')
    click_on 'Apply'
    open_edit_place_modal(id: event.id)
    page.find(:css, '.date-information-header').trigger('click')

    expect(page.find('#is_event')).to be_checked
  end

  private
  
  def create_map
    @map = create :map, :full_public, maintainer_email_address: 'foo@bar.org'
  end

  def show_date_information
    find('.toggle-switch', text: 'Date information').trigger('click')
  end

  def toggle_event_flag
    page.find('#is_event').trigger('click')
  end

  def toggle_end_date
    page.find('#set_end_date').trigger('click')
  end

  def create_place
    click_on('Create Place')
    find('.alert')
  end

  def set_date(position:, day:, month:, year:)
    page.find('#place_start_date').trigger('click')
    within(".#{position}") do
      find('.monthselect').find("option[value='#{month}']").select_option # Jan
      find('.yearselect').find("option[value='#{year}']").select_option # 2017
      find('td', text: day).click # 15
    end
  end
end

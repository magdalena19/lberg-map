feature 'Create event', :js do
  before do
    map = create :map, :full_public, maintainer_email_address: 'foo@bar.org'
    open_new_place_modal(map_token: map.secret_token)
    fill_in_valid_place_information(name: 'Place')
    show_date_form
    check_date_flag
  end

  scenario 'can set single date' do
    set_start_date(day: '2', month: '1', year: '2017', hours: '22', minutes: '0')
    find('.applyBtn').click
    create_place

    show_places_list_panel
    set_date_filter_range(range: '01.01.2017 22:00 - 03.01.2017 22:00')

    find('.name', text: 'Place').trigger('click')
    date = find('.event').text

    expect(date).to eq "02-01-2017 22:00"
  end
  
  scenario 'can set start and end date' do
    has_end_date
    set_start_date(day: '2', month: '1', year: '2017', hours: '22', minutes: '0')
    set_end_date(day: '3', month: '1', year: '2017', hours: '22', minutes: '0')
    find('.applyBtn').click
    create_place

    show_places_list_panel
    set_date_filter_range(range: '01.01.2017 22:00 - 04.01.2017 22:00')

    find('.name', text: 'Place').trigger('click')
    date = find('.event').text

    expect(date).to eq "02-01-2017 22:00 - 03-01-2017 22:00"
  end

  private
  
  # Date filter field
  def set_date_filter_range(range:)
    fill_in('search-date-input', with: range)
    find('.applyBtn').trigger('click')
  end

  # Date setting helpers (-> place/event form)
  def show_date_form
    page.find('.date-information-header').trigger('click')
  end

  def check_date_flag
    page.find('#is_event').trigger('click')
  end

  def has_end_date
    checkbox = page.find('#set_end_date')
    checkbox.trigger('click') unless checkbox.checked?
  end

  def set_start_date(day:, month:, year:, hours:, minutes:)
    set_date(position: 'left', day: day, month: month, year: year, hours: hours, minutes: minutes)
  end

  def set_end_date(day:, month:, year:, hours:, minutes:)
    set_date(position: 'right', day: day, month: month, year: year, hours: hours, minutes: minutes)
  end

  def set_date(position:, day:, month:, year:, hours:, minutes:)
    page.find('#place_start_date').trigger('click')
    within(".#{position}") do
      set_month(month: month)
      set_year(year: year)
      set_day(day: day)
      set_time(hours: hours, minutes: minutes)
    end
  end

  def set_day(day:)
    find_all('td.available:not(.off)', text: /\A#{day}\z/).first.click
  end

  def set_month(month:)
    find('.monthselect').find(:xpath, "option[#{month}]").select_option
  end

  def set_year(year:)
    find('.yearselect').find("option[value='#{year}']").select_option
  end

  def set_time(hours:, minutes:)
    find('.hourselect').find("option[value='#{hours}']").select_option
    find('.minuteselect').find("option[value='#{minutes}']").select_option
  end

  def create_place
    click_button('Create Place')
  end
end

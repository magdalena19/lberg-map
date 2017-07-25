feature 'Create event', :js do
  before do
    map = create :map, :full_public, maintainer_email_address: 'foo@bar.org'
    visit new_place_path(map_token: map.public_token)
    show_date_information
  end

  scenario 'event flag is false by default' do
    expect(page.find('#is_event')).not_to be_checked
  end

  scenario 'can enter dates if place is flagged as event' do
    expect(page).to have_css('#place_start_date')
  end

  scenario 'can set single date' do
    page.find('#is_event').trigger('click')

    expect(page).to have_css('#set_end_date')
  end

  scenario 'unchecking end date shows single date picker' do
    page.find('#is_event').trigger('click')
    page.find('#place_start_date').trigger('click')

    expect(page).to have_css('.single')
  end
  
  scenario 'checking end date shows double date range picker' do
    page.find('#is_event').trigger('click')
    field_value = find('#place_start_date').value
    page.find('#set_end_date').trigger('click')
    page.find('#place_start_date').trigger('click')

    expect(page).to have_css('.left')
    expect(page).to have_css('.right')
    expect(page.find('#place_start_date').value). to eq "#{field_value} - #{field_value}"
  end

  scenario 'checking end date shows date range value in input' do
    page.find('#is_event').trigger('click')
    field_value = find('#place_start_date').value
    page.find('#set_end_date').trigger('click')

    expect(page.find('#place_start_date').value). to eq "#{field_value} - #{field_value}"
  end
end

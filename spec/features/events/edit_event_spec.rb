feature 'Edit event', :js do
  scenario 'show event form elements' do
    event = create :event, :future, map: create(:map, :full_public)
    visit edit_place_path(id: event.id, map_token: event.map.public_token)

    expect(page.find('#is_event')).to be_checked
    expect(page.find('#place_start_date').value).to eq [event.start_date, event.end_date].join(' - ')
  end
end

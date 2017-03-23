feature 'Edit event' do
  scenario 'event checkbox is checked when place is event', js: true do
    event = create :event, :future, map: create(:map, :full_public)
    visit edit_place_path(id: event.id, map_token: event.map.public_token)
    expect(page.find('#place_event')).to be_checked
  end
end

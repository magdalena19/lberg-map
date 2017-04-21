feature 'Edit event', :js do
  scenario 'event checkbox is checked when place is event' do
    event = create :event, :future, map: create(:map, :full_public)
    visit edit_place_path(id: event.id, map_token: event.map.public_token)
    page.find(:css, '.date-information-header').trigger('click')

    expect(page.find('#is_event')).to be_checked
  end
end

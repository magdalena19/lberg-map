feature 'Edit event' do
  before do
    create :settings, :public
  end

  scenario 'event checkbox is checked when place is event', js: true do
    event = create :event, :future
    visit edit_place_path(id: event.id)
    expect(page.find('#place_event')).to be_checked
  end
end

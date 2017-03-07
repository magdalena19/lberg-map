# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Map', js: true do
  before do
    create :settings, :public
    spawn_categories
    create :place, :reviewed, id: 666

    visit '/'
    click_on('Select this language')
  end

  scenario 'has place edit buttons' do
    page.find('.leaflet-marker-icon').trigger('click')
    expect(page).to have_css('.edit-place')
  end
end

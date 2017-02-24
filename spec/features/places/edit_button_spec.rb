feature 'edit button' do
  before do
    create :settings, :public
  end

  scenario 'is visible', js: true do
    create :place, :reviewed
    login_as_user
    page.find('.leaflet-marker-icon').trigger('click')
    expect(page).to have_css('.edit-place')
  end
end

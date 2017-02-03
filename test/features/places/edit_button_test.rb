require_relative '../../test_helper'

feature 'edit button' do
  before do
    @place = create(:place, :reviewed)
  end

  scenario 'is visible', js: true do
    login_as_user
    sleep(1)
    page.find('.leaflet-marker-icon').trigger('click')
    page.must_have_css('.edit-place')
  end
end

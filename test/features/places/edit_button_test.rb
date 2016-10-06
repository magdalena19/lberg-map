require 'test_helper'

feature 'edit button' do
  before do
    @category = Category.new(name_en: 'Playground')
    @category.save
    Category.new(name_en: 'Hospital').save
    @place = Place.new(
      name: 'Magda',
      street: 'Magdalenenstraße',
      house_number: '19',
      postal_code: '10365',
      city: 'Berlin',
      categories: @category.id,
      homepage: 'https://heise.de',
      email: 'foo@bar.org',
      phone: '030 2304958',
      description_en: '<center><b>This is the description.</b></center>',
      latitude: 52.5,
      longitude: 13.5,
      reviewed: true
    )
    @place.save
  end

  scenario 'is visible', js: true do
    login
    sleep(1)
    page.find('.leaflet-marker-icon').trigger('click')
    page.must_have_css('.edit-place')
  end
end

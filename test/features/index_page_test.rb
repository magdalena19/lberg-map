require 'test_helper'

feature 'Index page' do
  scenario 'Index page is loading' do
    visit root_path
    page.must_have_content 'Point to a new place'
    page.must_have_css('#map')
  end
end
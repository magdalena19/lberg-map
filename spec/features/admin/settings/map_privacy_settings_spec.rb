feature 'Map privacy settings' do
  context 'Public maps with restricted access' do
    before do
      create :settings, :public_restricted
    end

    scenario 'Cannot insert places / events via form', :js do
      visit '/en'

      expect(page).not_to have_css('.place-control-container')
    end

    scenario 'Cannot edit places / events via place list index', :js do
      create :place, :reviewed, name: 'SomePlace'
      visit places_path

      expect(page).not_to have_css('.glyphicon-pencil')
    end

    scenario 'Cannot edit places / events via place via sidebar', :js do
      create :place, :reviewed, name: 'SomePlace'
      visit '/en'
      page.find('.name').trigger('click')

      expect(page).not_to have_css('.glyphicon-pencil')
    end
  end

  context 'Private maps' do
    before do
      create :settings, :private
    end

    scenario 'Have to login before can do anything', :js do
      visit '/en/places/new'

      expect(page).to have_css('#sessions_email')
      expect(page).to have_css('#sessions_password')
    end
  end
end

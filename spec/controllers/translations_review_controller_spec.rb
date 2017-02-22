require 'rails_helper'

describe TranslationsReviewController do
  before do
    create :settings, :public
    login_as user
    place_with_unreviewed_changes.update_attributes(name: 'Magda', description: 'This is an updated description.')
  end

  let(:new_place) { create :place, :unreviewed }
  let(:place_with_unreviewed_changes) { create :place, :reviewed, name: 'Magda19', description_en: 'This is a description.' }
  let(:translations) { place_with_unreviewed_changes.translations }
  let(:user) { create :user, name: 'Norbert' }
  
  context 'GET #confirm' do
    it 'confirms unreviewed translations' do
      translation = translations.find_by(description: 'This is an updated description.')
      get :confirm, id: translation.id

      translation.reload
      expect(translation.versions.count).to eq(1)
      expect(translation.description).to eq('This is an updated description.')
    end
  end

  context 'GET #refuse' do
    it 'deletes only unreviewed translation versions' do
      translation = translations.find_by(description: 'This is an updated description.')
      get :refuse, id: translation.id

      translation.reload
      expect(translation.versions.count).to eq(1)
      expect(translation.description).to eq('This is a description.')
    end
  end
end

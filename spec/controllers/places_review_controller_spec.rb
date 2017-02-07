require 'rails_helper'

describe PlacesReviewController do
  let(:user) { create :user }
  let (:new_place) { create :place, :unreviewed, name: 'SomeName' }

  before do
    login_as user
  end

  context 'GET #review' do
    it 'populates the right place to be reviewed' do
      get :review, id: new_place.id
      
      expect(assigns(:unreviewed_place)).to eq(new_place)
      expect(assigns(:reviewed_place)).to be_nil
    end

    it 'renders review template' do
      get :review, id: new_place.id
      expect(response).to render_template 'places_review/review'
    end
  end

  context 'GET #confirm' do
    it 'accepts changes and does not show place to be reviewed' do
      get :confirm, id: new_place.id

      new_place.reload
      expect(new_place.reviewed).to be true
    end

    # TODO is that right??
    it 'redirects to places review index path' do
      get :confirm, id: new_place.id
      expect(response).to redirect_to places_review_index_path
    end
  end

  context 'GET #refuse' do
    it 'deletes only unreviewed version' do
      place_with_changes = create :place, :reviewed, name: 'SomeName'
      place_with_changes.update_attributes(name: 'SomeOtherName', description: 'This is an updated description.')

      login_as user
      get :refuse, id: place_with_changes.id

      place_with_changes.reload
      expect(Place.find_by(name: 'SomeName')).to eq(place_with_changes)
    end

    it 'redirects to places review index path' do
      another_unreviewed_place = create :place, :unreviewed

      get :refuse, id: another_unreviewed_place.id
      expect(response).to redirect_to places_review_index_path
    end

    it 'removes new places entirely' do
      another_unreviewed_place = create :place, :unreviewed

      get :refuse, id: another_unreviewed_place.id
      expect(Place.all).not_to include(another_unreviewed_place)
    end

  end
end

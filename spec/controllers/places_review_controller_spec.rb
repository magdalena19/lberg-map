require 'rails_helper'

describe PlacesReviewController do
  before do
    login_as user
  end

  let(:user) { create :user }
  let(:map) { create :map, :full_public }
  let(:new_place) { create :place, :unreviewed, name: 'SomeName', map: map }

  context 'GET #review' do
    it 'populates the right place to be reviewed' do
      get :review, id: new_place.id, map_token: map.public_token
      
      expect(assigns(:unreviewed_place)).to eq(new_place)
      expect(assigns(:reviewed_place)).to be_nil
    end

    it 'renders review template' do
      get :review, id: new_place.id, map_token: map.public_token
      expect(response).to render_template 'places_review/review'
    end
  end

  context 'GET #confirm' do
    it 'accepts changes and does not show place to be reviewed' do
      get :confirm, id: new_place.id, map_token: map.public_token

      new_place.reload
      expect(new_place.reviewed).to be true
    end

    # TODO is that right??
    it 'redirects to places review index path' do
      get :confirm, id: new_place.id, map_token: map.public_token
      expect(response).to redirect_to places_review_index_path
    end
  end

  context 'GET #refuse' do
    before do
      @map = create :map, :full_public
      @another_unreviewed_place = create :place, :unreviewed, map: @map
    end

    it 'deletes only unreviewed version' do
      place_with_changes = create :place, :reviewed, name: 'SomeName', map: @map
      place_with_changes.update_attributes(name: 'SomeOtherName', description: 'This is an updated description.')

      login_as user
      get :refuse, id: place_with_changes.id, map_token: @map.public_token

      place_with_changes.reload
      expect(Place.find_by(name: 'SomeName')).to eq(place_with_changes)
    end

    it 'redirects to places review index path' do
      get :refuse, id: @another_unreviewed_place.id, map_token: @map.public_token

      expect(response).to redirect_to places_review_index_path
    end

    it 'removes new places entirely' do
      get :refuse, id: @another_unreviewed_place.id, map_token: @map.public_token
      expect(Place.all).not_to include(@another_unreviewed_place)
    end
  end
end

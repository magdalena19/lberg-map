require 'rails_helper'

describe ReviewController do
  before do
    @map = create :map, :full_public
    @new_unreviewed_place = create :place, :unreviewed, map: @map
    @reviewed_place = create :place, :reviewed, map: @map

    @controller = PlacesController.new
    put :update, id: @reviewed_place, place: { name: 'Magda' }, map_token: @map.secret_token
    put :update, id: @reviewed_place, place: { description_en: 'This is an updated description' }, map_token: @map.secret_token
    @controller = ReviewController.new
  end

  let(:user) { create :user }

  context 'GET #review_index' do
    it 'populates items to be reviewed if signed in' do
      login_as user
      get :review_index, map_token: @map.public_token
      expect(assigns(:places_to_review).count).to eq 2
      expect(assigns(:unreviewed_translations).count).to eq 3
    end

    it 'renders review index template' do
      login_as user
      get :review_index, map_token: @map.public_token
      expect(response).to render_template 'review/review_index'
    end

    it 'does not populates items if not signed in' do
      logout
      get :review_index, map_token: @map.public_token
      expect(response).to redirect_to login_path
    end
  end
end

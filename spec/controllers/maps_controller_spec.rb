require 'rails_helper'

RSpec.describe MapsController, type: :controller do

  describe 'GET #show' do
    before do
      @map = create :map, :full_public
    end

    it 'returns http success' do
      get :show, map_token: @map.public_token
      expect(response).to have_http_status(:success)
    end

    it 'populates all places in map in @places_to_show' do
      @places = create_list(:place, 3, :reviewed, map: @map)
      get :show, map_token: @map.public_token
      expect(assigns(:places_to_show).sort_by(&:id)).to eq @places
    end
  end

  describe 'GET #new' do
    before do
      login_as create :user
    end

    it 'can access new map ressource' do
      expect(response).to have_http_status(:success)
    end

    it 'populates new map in @map' do
      get :new
      expect(assigns(:map)).to be_a(Map)
    end
    
    it 'renders :new template' do
      get :new
      expect(response).to render_template :new
    end

    it 'rejects access if not logged in'
  end

  describe 'POST #create' do
    it 'creates new map in @map' do
      expect {
        post :create, map: attributes_for(:map, :full_public)
      }.to change { Map.count }.by(1)
    end

    it 'redirects to map' do
      post :create, map: attributes_for(:map, :full_public)
      new_map = assigns(:map)
      expect(response).to redirect_to map_path(new_map.secret_token)
    end

    it 'rejects access if not logged in'
  end

  describe 'GET #edit' do
    let(:map) { create :map, :full_public }

    before do
      login_as create :user
      get :edit, map_token: map.secret_token
    end

    it 'populates map in @map' do
      expect(assigns(:map)).to eq map
    end
    
    it 'renders :edit template' do
      expect(response).to render_template :edit
    end

    it 'rejects access if not logged in'
  end

  describe 'PATCH #update' do
    let(:map) { create :map, :full_public }

    before do
      login_as create :user
      patch :update, map_token: map.secret_token, map: { title: 'ChangedTitle' }
    end

    it 'populates changes' do
      expect(assigns(:map).title).to eq 'ChangedTitle'
    end
    
    it 'rejects access if not logged in' do
      # expect(:get => new_map_path).not_to be_routable
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes map if owned by current user'
    it 'rejects deleting map if not owned by current user'
    it 'rejects access if not logged in'
  end

end

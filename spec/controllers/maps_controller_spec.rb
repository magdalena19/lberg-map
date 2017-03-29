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


  describe 'GET #index' do
    let(:user) { create :user, name: 'user' }
    let(:public_map) { create :map, :full_public, user: user }
    let(:private_map) { create :map, :private, user: user }

    let(:other_user) { create :user, name: 'other_user' }
    let(:other_map) { create :map, :full_public, title: 'OtherMap', user: other_user }

    context 'As registered user' do
      before do
        login_as user
        get :index
      end

      it 'populates all user maps in @maps' do
        expect(assigns(:maps)).to eq user.maps
      end

      it 'renders :index template' do
        expect(response).to render_template :index
      end

      it 'does not include other users maps' do
        maps = assigns(:maps)

        other_user.maps.each do |map|
          expect(maps).not_to include map
        end
      end
    end

    context 'If not registered' do
      it 'redirects to landing page if not signed in' do
        logout
        get :index
        expect(response).to redirect_to landing_page_path
      end
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

    it 'rejects access if not logged in' do
      skip "Works but don't know how to write test appropriately"
      logout
      get :new
      expect(response).not_to render_template :new
    end
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
    let(:user) { create :user }
    let(:map) { create :map, :full_public, user: user }

    before do
      login_as user
      get :edit, map_token: map.secret_token
    end

    it 'populates map in @map' do
      expect(assigns(:map)).to eq map
    end

    it 'renders :edit template' do
      expect(response).to render_template :edit
    end

    context 'rejects editing' do
      it 'if not owned by current user' do
        login_as create :user, name: 'AnotherUser'
        expect(get: edit_map_path(map_token: map.secret_token)).not_to be_routable
      end

      it 'if is guest user' do
        logout
        expect(get: edit_map_path(map_token: map.secret_token)).not_to be_routable
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create :user }
    let(:map) { create :map, :full_public, user: user }

    it 'populates changes' do
      login_as user
      patch :update, map_token: map.secret_token, map: { title: 'ChangedTitle' }
      expect(assigns(:map).title).to eq 'ChangedTitle'
    end

    context 'rejects editing' do
      it 'if not owned by current user' do
        login_as create :user, name: 'AnotherUser'
        expect(get: edit_map_path(map_token: map.secret_token)).not_to be_routable
      end

      it 'if is guest user' do
        logout
        expect(get: edit_map_path(map_token: map.secret_token)).not_to be_routable
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      login_as create :user, name: 'user'
      @map = create :map, :full_public, user: User.first
    end

    it 'deletes map' do
      expect {
        delete :destroy, map_token: @map.secret_token
      }.to change { Map.count }.by(-1)
    end

    context 'rejects deleting' do
      it 'if not owned by current user' do
        login_as create :user, name: 'AnotherUser'
        expect(delete: destroy_map_path(map_token: @map.secret_token)).not_to be_routable
      end

      it 'if not logged in' do
        logout
        expect(delete: destroy_map_path(map_token: @map.secret_token)).not_to be_routable
      end
    end
  end

  describe 'GET #share_map' do
    context 'as privileged guest user' do
      before do
        @map = create :map, :full_public, user: User.first
        get :share_map, map_token: @map.secret_token
      end

      it 'renders proper template' do
        expect(page).to render_template :share_map
      end

      it 'populates map in @map' do
        expect(assigns(:map)).to eq @map
      end
    end

    context 'POST #send_invitation'
    before do
      @map = create :map, :full_public, user: User.first
    end

    it 'does not break if no email addresses entered' do
      post :send_invitations, map_token: @map.secret_token
    end

    it 'should enqueue invitations for delivery in background' do
      Sidekiq::Testing.fake! do
        expect{
          post :send_invitations, map_token: @map.secret_token, guests: 'foo@bar.com, schnabel@tier.com', collaborators: 'me@you.org'
        }.to change{ MapInvitationWorker.jobs.size }.by(3)
      end
    end

    it 'should redirect after enqueing invitations and show flash message' do
      Sidekiq::Testing.fake! do
        post :send_invitations, map_token: @map.secret_token, guests: 'foo@bar.com, schnabel@tier.com', collaborators: 'me@you.org'
      end
      expect(response).to redirect_to map_path(map_token: @map.secret_token)
      expect(flash[:success]).to eq 'Successfully sent invitations!'
    end
  end
end
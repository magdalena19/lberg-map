require 'rails_helper'

RSpec.describe MapsController, type: :controller do
  describe 'Password protection' do
    before do
      @map = create :map, :full_public, password: 'secret', password_confirmation: 'secret'
    end

    it 'access ressource if map is unlocked' do
      session[:unlocked_maps] = [@map.id]
      get :show, map_token: @map.secret_token

      expect(assigns(:map)).to be_a(Map)
    end

    it 'returns success for correct password' do
      xhr :get, :unlock, map_token: @map.secret_token, password: 'secret'

      expect(response).to have_http_status 200
    end

    it 'returns error for incorrect password' do
      xhr :get, :unlock, map_token: @map.secret_token, password: 'wrong'

      expect(response).to have_http_status 401
    end

    it 'does not need to unlock already unlocked routes' do
      session[:unlocked_maps] = [@map.secret_token, 'some_other_token']
      xhr :get, :needs_unlock, map_token: @map.secret_token
      unlocked_maps = JSON.parse(response.body)
      expectation = { 'needs_unlock' => false }

      expect(unlocked_maps).to eq expectation
    end

    it 'does not need to unlock non-password-protected maps' do
      non_protected_map = create :map, :full_public
      xhr :get, :needs_unlock, map_token: non_protected_map.secret_token
      unlocked_maps = JSON.parse(response.body)
      expectation = { 'needs_unlock' => false }

      expect(unlocked_maps).to eq expectation
    end

    context 'XHR #show' do
      it 'Does not receive any data without password via secret link' do
        xhr :get, :show, format: :json, map_token: @map.secret_token

        expect(response.status).to eq 401
      end

      it 'Does not demand password via public link' do
        create :place, :reviewed, map: @map
        xhr :get, :show, format: :json, map_token: @map.public_token
        coordinates_from_json = JSON.parse(response.body)['places'].first['geometry']['coordinates']

        expect(response.status).to eq 200
        expect(coordinates_from_json).to eq [13.45, 52.5]
      end

      it 'Updates maps last visit attribute' do
        create :settings, expiry_days: 10
        map = create :map, :public_guest_map, last_visit: Date.today - 2.days
        xhr :get, :show, format: :json, map_token: map.public_token

        expect(map.reload.last_visit).to eq Date.today
        expect(map.reload.days_left_till_destruction).to eq 10
      end
    end

    context 'GET #edit' do
      it 'Cannot edit protected map if no password supplied' do
        get :edit, map_token: @map.secret_token

        expect(response.status).to eq 302
      end

      it 'Can edit protected map if unlocked' do
        session[:unlocked_maps] = @map.secret_token
        get :edit, map_token: @map.secret_token

        expect(response.status).to eq 200
      end
    end

    context 'PATCH #update' do
      it 'Cannot update protected map if no password supplied' do
        patch :update, map_token: @map.secret_token, map: { title: 'Somethin different' }

        expect(response.status).to eq 302
      end

      it 'can update map if unlocked' do
        session[:unlocked_maps] = [@map.secret_token]
        patch :update, map_token: @map.secret_token, map: { title: 'ChangedTitle' }

        expect(@map.reload.title).to eq 'ChangedTitle'
      end

      it 'can unset password if unlocked' do
        session[:unlocked_maps] = [@map.secret_token]
        patch :update, map_token: @map.secret_token, map: { password_protect: false }

        expect(@map.reload.password_digest).to be_nil
      end
    end
  end

  describe 'GET #show' do
    before do
      @map = create :map, :full_public
    end

    it 'returns http success' do
      get :show, map_token: @map.public_token

      expect(response).to have_http_status(:success)
    end

    it 'has indicator for poi presence' do
      @places = create_list(:place, 3, :reviewed, map: @map)
      get :show, map_token: @map.public_token

      expect(assigns(:reviewed_places_available)).to be true
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
      it 'redirects to landing page if not signed in or no session maps' do
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

    it 'stores new map in session cookie' do
      post :create, map: attributes_for(:map, :full_public)

      expect(session[:maps].count).to be 1
    end

    it 'sets auto_translation to false if translation engine is none' do
      post :create, map: attributes_for(:map, :full_public, translation_engine: 'none')
      map = assigns(:map)

      expect(map.auto_translate).to be false
    end
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

    it 'cannot get edit if requested via public token' do
      expect(get: "/#{map.public_token}/edit").not_to be_routable
    end
  end

  describe 'PATCH #update' do
    let(:user) { create :user }
    let(:map) { create :map, :full_public, user: user }

    it 'populates changes' do
      patch :update, map_token: map.secret_token, map: { title: 'ChangedTitle' }

      expect(assigns(:map).title).to eq 'ChangedTitle'
    end

    it 'cannot update if requested via public token' do
      expect(patch: "/#{map.public_token}").not_to be_routable
    end
  end

  describe 'DELETE #destroy' do
    before do
      @map = create :map, :full_public, user: User.first
    end

    it 'deletes map' do
      expect {
        delete :destroy, map_token: @map.secret_token
      }.to change { Map.count }.by(-1)
    end

    it 'cannot destroy if requested via public token' do
      expect(delete: "/#{@map.public_token}").not_to be_routable
    end
  end

  describe 'GET #share_map' do
    context 'POST #send_invitation'
    before do
      @map = create :map, :full_public, user: User.first
    end

    it 'should enqueue invitations for delivery in background' do
      Sidekiq::Testing.fake! do
        expect{
          xhr :post, :send_invitations,  map_guests: 'foo@bar.com, schnabel@tier.com', map_admins: 'me@you.org', id: @map.id
        }.to change{ MapInvitationWorker.jobs.size }.by(3)
      end
    end
  end
end

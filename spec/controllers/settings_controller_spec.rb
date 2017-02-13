require 'rails_helper'

describe Admin::SettingsController, type: :controller  do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template :index
    end

    it 'populates settings in @settings' do
      get :index
      expect(assigns(:settings)).not_to be_nil
    end

    context 'rejects access' do
      it 'if not admin' do
        user = create :user
        login_as_user
        get :index
        expect(response).to redirect_to root_path
      end

      it 'if guest user' do
        logout
        get :index
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST #create' do
    it 'does not respond to post' do
      admin = create :user, :admin
      login_as admin
      expect {
        post :create, setting: { site_title: 'SomeTitle' }
      }.to raise_error(ActionController::UrlGenerationError)
    end
  end

  describe 'PUT #update' do
    it 'can update settings'

    context 'rejects update' do
      it 'if not admin'
      it 'if guest user'
    end
  end
end

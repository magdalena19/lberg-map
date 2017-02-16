require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      login_as create :user, :admin
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template :index
    end

    context 'rejects access' do
      it 'if not admin' do
        login_as create :user
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
end

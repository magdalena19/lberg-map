require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      admin = create :user, :admin
      login_as admin
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template :index
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

end

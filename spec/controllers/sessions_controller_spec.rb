require 'rails_helper'

describe SessionsController do
  context 'POST #create' do
    it 'Can login' do
      user = create :user, name: 'Norbert'

      post :create, sessions: {
        email: user.email,
        password: 'secret'
      }

      expect(session[:user_id]).to eq(user.id)
    end
  end

  context 'DESTROY #destroy' do
    it 'Can logout' do
      user = create :user, name: 'Norbert'
      login_as user
      get :destroy

      expect(session[:user_id]).to be_nil
    end
  end
end

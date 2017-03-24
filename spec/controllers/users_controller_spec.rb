require 'rails_helper'

describe UsersController do
	let(:user) { create :user, name: 'Norbert' }

  context 'GET #edit' do
    it 'should populate user' do
      login_as user
      get :edit, id: user.id
      expect(assigns(:user)).to eq(user)
    end

    it 'should render :edit template' do
      login_as user
      expect(

        get :edit, id: user.id
      ).to render_template :edit
    end

    context 'reject editing' do
      it 'if not logged in' do
        get :edit, id: user.id

        expect(response).to redirect_to login_path
      end

      it 'other groups users' do
        login_as user
        other_user = create :user, name: 'Susanne'
        get :edit, id: other_user.id

        expect(response).to redirect_to root_path
      end
    end
  end

  context 'PATCH #update' do
    it 'should update if attributes are valid' do
      login_as user
      put :update, id: user.id, user: {
        name: 'SomeOtherName',
        email: 'foo@bar.batz',
        password: 'schnipp',
        password_confirmation: 'schnipp' }

      user.reload do |user|
        expect(user.email).to eq('foo@bar.batz')
        expect(user.name).to eq('SomeOtherName')
      end
    end

    context 'reject updates' do
      it 'if not logged in' do
        patch :update, id: user.id, user: { name: 'SomeOtherName' }

        expect(response).to redirect_to login_path
        expect(user.reload.name).not_to eq('SomeOtherName')
      end

      it 'on other users' do
        login_as user
        other_user = create :user
        patch :update, id: other_user.id, user: { name: 'SomeOtherName' }

        expect(response).to redirect_to root_path
        expect(other_user.reload.name).not_to eq('SomeOtherName')
      end
    end
  end
end

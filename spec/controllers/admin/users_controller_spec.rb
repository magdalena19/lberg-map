require 'rails_helper'

describe Admin::UsersController do
  before do
    create :settings
  end

  context 'GET #edit' do
    let(:admin_user) { create :user, :admin }

    it 'cannot delete currently logged in admin user' do
      login_as admin_user

      expect { delete(:destroy, id: admin_user.id) }.to change { User.count }.by(0)
    end
  end
end

require 'rails_helper'

describe AnnouncementsController do
  let(:user1) {create :user, name: 'Susanne'}
  let(:user2) {create :user, name: 'Norbert'}
  let(:admin) {create :user, :admin, name: 'Admin'}
  let(:announcement) {create :announcement, header: 'something', content: 'something', user: user1}

  before do
    login_as user1
    create :settings, :public
  end

  context 'GET #index' do
    it 'populates all announcements in @announcements' do
      get :index
      expect(assigns(:announcements)).to include(announcement)
    end

    it 'renders :index template' do
      get :index
      expect(response).to render_template 'announcements/index'
    end

    it 'redirects if not logged in' do
      logout
      get :index
      expect(response).to redirect_to login_path
    end
  end

  context 'GET #edit' do
    it 'populates the correct announcement in @announcement' do
      get :edit, id: announcement.id
      expect(assigns(:announcement)).to eq(announcement)
    end

    it 'renders :edit template' do
      get :edit, id: announcement.id
      expect(response).to render_template 'announcements/edit'
    end

    it 'redirects if not logged in' do
      logout
      get :edit, id: announcement.id
      expect(response).to redirect_to login_path
    end
  end

  context 'GET #new' do
    it 'populates a new announcement in @announcement' do
      get :new
      expect(assigns(:announcement)).to be_a(Announcement)
    end

    it 'renders :new template' do
      get :new
      expect(response).to render_template 'announcements/new'
    end

    it 'redirects if not logged in' do
      logout
      get :new
      expect(response).to redirect_to login_path
    end
  end

  context 'GET #show' do
    it 'populates the correct announcement in @announcement' do
      get :show, id: announcement.id
      expect(assigns(:announcement)).to eq(announcement)
    end

    it 'renders :edit template' do
      get :show, id: announcement.id
      expect(response).to render_template 'announcements/show'
    end

    it 'redirects if not logged in' do
      logout
      get :show, id: announcement.id
      expect(response).to redirect_to login_path
    end
  end

  context 'POST #create' do
    it 'creates new announcement' do
      expect {
        post :create, announcement: attributes_for(:announcement)
      }.to change { Announcement.count }.by(1)
    end

    it 'sets correct ownership' do
      post :create, announcement: attributes_for(:announcement)
      expect(Announcement.find_by(header: 'SomeAnnouncement').user).to eq(user1)
    end

    it 'redirects to announcement index' do
      post :create, announcement: attributes_for(:announcement)
      expect(response).to redirect_to root_path
    end

    context 'rejects new announcement' do
      it 'if not logged in' do
        logout
        expect {
          post :create, announcement: attributes_for(:announcement)
        }.to change { Announcement.count }.by(0)
        expect(response).to redirect_to login_path
      end
    end
  end

  context 'PUT #update' do
    it 'accepts update on own announcement' do
      login_as user1

      expect {
        put :update, id: announcement.id, announcement: { header: 'Changed!',
                                                          content: 'Changed!' }
      }.to change { announcement.reload.header }.from('something').to('Changed!')
    end
    it 'redirects to announcement index' do
      login_as user1

      put :update, id: announcement.id, announcement: { header: 'Changed!',
                                                        content: 'Changed!' }
      expect(response).to redirect_to announcements_path
    end


    it 'accepts updating other users announcement if is admin' do
      announce_of_user1 = create :announcement, header: 'SomeHeader', user: user1
      login_as admin

      expect{
        put :update, id: announce_of_user1.id, announcement: { header: 'Changed!',
                                                               content: 'Changed!' }
      }.to change { announce_of_user1.reload.header }.to('Changed!')
    end

    context 'rejects update' do
      it 'if not logged in' do
        logout
        put :update, id: announcement.id, announcement: { header: 'Changed!',
                                                          content: 'Changed!' }

        expect(response.committed?).to be false
        expect(response).to redirect_to login_path
      end

      it 'if is other users announcement' do
        announce_of_user1 = create :announcement, user: user1
        login_as user2
        put :update, id: announcement.id, announcement: { header: 'Changed!',
                                                          content: 'Changed!' }
        expect(response.committed?).to be false
        expect(response).to redirect_to announcements_path
      end
    end
  end

  context 'DELETE #destroy' do
    it 'deletes own announcement' do
      announce_of_user1 = create :announcement, user: user1
      login_as user1

      expect {
        delete :destroy, id: announce_of_user1.id
      }.to change { Announcement.count }.from(1).to(0)
    end

    it 'redirects to announcement index' do
      announce_of_user1 = create :announcement, user: user1
      login_as user1
      delete :destroy, id: announce_of_user1.id

      expect(response).to redirect_to root_path
    end

    it 'delete other users announcement if is admin' do
      announce_of_user1 = create :announcement, header: 'SomeHeader', user: user1
      login_as admin

      expect{
        delete :destroy, id: announce_of_user1.id
      }.to change { Announcement.count }.by(-1)
    end

    context 'rejects deletion' do
      it 'if not logged in' do
        logout
        delete :destroy, id: announcement.id

        expect(response.committed?).to be false
        expect(response).to redirect_to login_path
      end

      it 'if is other users announcement' do
        announce_of_user1 = create :announcement, user: user1
        login_as user2
        expect {
          delete :destroy, id: announce_of_user1.id
        }.to change { Announcement.count }.by(0)
        expect(response).to redirect_to announcements_path
      end
    end
  end
end

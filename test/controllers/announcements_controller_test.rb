require 'test_helper'

class AnnouncementsControllerTest < ActionController::TestCase
  def setup
    @user1 = users :Susanne
    @user2 = users :Norbert
    @admin = users :Admin
    @announcement = Announcement.new(header: 'something', content: 'something')
    @announcement.user = @user1
    @announcement.save
  end

  test 'Cannot do anything without being logged in' do
    session[:user_id] = nil

    assert_difference 'Announcement.count', 0 do
      post :create, announcement: { header: 'another header',
                                    content: 'another content' }
    end

    assert_difference 'Announcement.count', 0 do
      delete :destroy, id: @announcement.id
    end

    put :update, id: @announcement.id, announcement: { header: 'Changed!',
                                                       content: 'Changed!' }
    assert_equal 'something', @announcement.reload.header
  end

  test 'Can add new announcement if logged in' do
    session[:user_id] = @user2.id
    assert_difference 'Announcement.count' do
      post :create, announcement: { header: 'another header',
                                    content: 'another content' }
    end
  end

  test 'Can modify own announcements' do
    session[:user_id] = @user1.id

    put :update, id: @announcement.id, announcement: { header: 'Changed!',
                                                       content: 'Changed!' }
    assert_equal 'Changed!', @announcement.reload.header

    assert_difference 'Announcement.count', -1 do
      delete :destroy, id: @announcement.id
    end
  end

  test 'Cannot modify other users announcements' do
    session[:user_id] = @user2.id
    assert_difference 'Announcement.count', 0 do
      delete :destroy, id: @announcement.id
    end

    put :update, id: @announcement.id, announcement: { header: 'Changed!',
                                                       content: 'Changed!' }
    assert_equal 'something', @announcement.reload.header
  end

  test 'Can do anything as admin' do
    session[:user_id] = @admin.id

    put :update, id: @announcement.id, announcement: { header: 'Changed!',
                                                       content: 'Changed!' }
      assert_equal 'Changed!', @announcement.reload.header

    assert_difference 'Announcement.count', -1 do
      delete :destroy, id: @announcement.id
    end
  end
end

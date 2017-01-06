require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  def setup
    @announcement = Announcement.new(header: 'some header',
                                     content: 'some content')
  end

  # Check validation working
  test 'Header has to be min 5 and max 100 characters' do
    ['', 'a' * 4, 'a' * 101].each do |e|
      assert_not @announcement.update_attributes(header: e)
    end
  end

  test 'Content cannot be blank' do
    assert_not @announcement.update_attributes(content: '')
  end

  test 'html should be sanitized' do
    @announcement_with_html = Announcement.new(
      header: "SomeHeader",
      content: '<center>SomeContent</center>'
    )
    @announcement_with_html.save
    assert_equal 'SomeContent', Announcement.find(@announcement_with_html.id).content
  end
end

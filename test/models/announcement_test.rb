require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  def setup
    @announcement = Announcement.new({header: 'some header',
                                      content: 'some content' })
  end

  # Check validation working
  test "Header has to be min 5 and max 30 elements" do
    ['', 'a'*4 , 'a'*31].each do |e|
      assert_not @announcement.update_attributes(header: e)
    end
  end

  test "Content cannot be blank" do
    assert_not @announcement.update_attributes(content: '')
  end
end

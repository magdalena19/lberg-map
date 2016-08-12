module AnnouncementsHelper
  def last_announcements_created
    Announcement.all.sort_by(&:created_at).reverse
  end
end

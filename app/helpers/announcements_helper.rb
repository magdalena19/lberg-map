module AnnouncementsHelper
  def last_announcements_created(n)
    Announcement.all.sort_by(&:created_at).reverse[0..n-1]
  end
end

module AnnouncementsHelper
  def last_announcements_created
    Announcement.all.sort_by(&:created_at).reverse
  end

  def announcements_chronicle_header(announcement)
    "#{t('manage_announcements.created_at')} #{announcement.created_at.strftime("%d-%m-%Y")} #{t('manage_announcements.created_by')} #{announcement.user.name} ".html_safe
  end
end

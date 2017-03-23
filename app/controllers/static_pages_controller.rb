class StaticPagesController < ApplicationController
  before_action :set_map

  def choose_locale
  end

  def about
  end

  # TODO Move to maps
  def chronicle
    @announcements = Announcement.all.sort_by(&:created_at).reverse
  end
end

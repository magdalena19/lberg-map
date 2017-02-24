class StaticPagesController < ApplicationController
  before_action :require_login_if_private_map, except: [:index]

  def index
  end

  def map
    @categories = Category.all
    @announcements = Announcement.all.sort_by(&:created_at).reverse
    @last_places_created = last_places_created
    @latitude = params[:latitude]
    @longitude = params[:longitude]

    respond_to do |format|
      format.json { render json: places_to_show.map(&:geojson) }
      format.html
    end
  end

  def about
  end

  def chronicle
    @announcements = Announcement.all.sort_by(&:created_at).reverse
  end

  private

  def places_to_show
    (Place.reviewed_places + places_from_session).uniq
  end

  def last_places_created
    places_to_show.sort_by(&:created_at).last(5)
  end
end

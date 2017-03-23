class MapsController < ApplicationController
  before_action :set_map

  def index
  end

  def show
    @categories = @map.categories.all
    @last_places_created = last_places_created
    @latitude = params[:latitude]
    @longitude = params[:longitude]
    @places_to_show = places_to_show

    respond_to do |format|
      format.json { render json: places_to_show.map(&:geojson), status: 200 }
      format.html
    end
  end

  private

  def places_to_show
    (@map.reviewed_places + places_from_session).uniq
  end

  def last_places_created
    places_to_show.sort_by(&:created_at).last(5)
  end
end

class StaticPagesController < ApplicationController
  def map
    @categories = Category.all
    @places_total = Place.count
    @announcements = Announcement.all.sort_by(&:created_at).reverse
    places = (Place.reviewed + places_from_session).uniq
    @last_places_created = places.sort_by(&:created_at).reverse.take(5)
    @latitude = params[:latitude]
    @longitude = params[:longitude]

    ## reponse for AJAX call
    if params[:category] == 'all'
      render json: (Place.reviewed + places_from_session).uniq.map(&:geojson)
    elsif params[:category]
      render json: (Place.reviewed_with_category(params[:category]) + places_from_session(params[:category])).uniq.map(&:geojson)
    end
  end

  def about
  end

  def chronicle
    @announcements = Announcement.all.sort_by(&:created_at).reverse
  end
end

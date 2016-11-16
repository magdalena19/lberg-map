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

  def contact
  end

  def chronicle
    @announcements = Announcement.all.sort_by(&:created_at).reverse
  end

  def places_from_session(category_id = nil)
    ids = cookies[:created_places_in_session]
    array = ids ? ids.split(',') : []
    if category_id
      Place.where(id: array).compact.find_all { |p| p.has_category?(category_id) }
    else
      Place.where(id: array)
    end
  end
end

class StaticPagesController < ApplicationController
  def map
    @categories = Category.all
    @announcements = Announcement.all.sort_by(&:created_at).reverse
    places = Place.reviewed + places_from_session(nil)
    @last_places_created = places.sort_by(&:created_at).reverse
    @latitude = params[:latitude]
    @longitude = params[:longitude]

    ## reponse for AJAX call
    if params[:category]
      if params[:category] == 'all'
        render json: Place.reviewed.map(&:geojson) + places_from_session(nil).map(&:geojson)
      else
        render json: Place.with_reviewed_category(params[:category]).map(&:geojson) + places_from_session(params[:category]).map(&:geojson)
      end
    end
  end

  def about
  end

  def chronicle
    @announcements = Announcement.all.sort_by(&:created_at).reverse
  end

  def places_from_session(category_id)
    ids = cookies[:created_places_in_session]
    array = ids ? ids.split(',') : []
    if category_id
      Place.where(id: array ).compact.find_all { |p| p.has_category?(category_id) }
    else
      Place.where(id: array )
    end
  end
end

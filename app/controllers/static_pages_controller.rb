class StaticPagesController < ApplicationController
  def map
    @categories = Category.all
    @announcements = Announcement.all.sort_by(&:created_at).reverse
    @last_places_created = last_places_created
    @latitude = params[:latitude]
    @longitude = params[:longitude]

    ## reponse for AJAX call
    render json: places_to_show.map(&:geojson) if params[:category]
  end

  def about
  end

  def chronicle
    @announcements = Announcement.all.sort_by(&:created_at).reverse
  end

  private

  def places_to_show
    if params[:category] == 'all'
      (Place.reviewed + places_from_session).uniq
    else
      (Place.reviewed_with_category(params[:category]) + places_from_session(params[:category])).uniq
    end
  end

  def last_places_created
    Place.order(:created_at).last(5)
  end
end

class StaticPagesController < ApplicationController
  def map
    @categories = Category.all
    @announcements = Announcement.all
    @last_places_created = Place.reviewed.sort_by(&:created_at).reverse

    ## reponse for AJAX call
    if params[:category]
      if params[:category] == 'all'
        render json: Place.reviewed.map(&:geojson)
      else
        render json: Place.with_reviewed_category(params[:category]).map(&:geojson)
      end
    end
  end

  def about
  end

  def chronicle
    @announcements = Announcement.all
  end
end

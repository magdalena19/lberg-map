class StaticPagesController < ApplicationController
  def map
    @places = Place.all
    @categories = Category.all
    @places_json = Place.all.map(&:geojson)

    ## reponse for AJAX call
    if params[:category]
      if params[:category] == 'all'
        render json: @places_json
      else
        render json: Place.tagged_with(params[:category]).map(&:geojson)
      end
    end
  end

  def about
  end
end

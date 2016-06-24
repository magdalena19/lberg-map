class StaticPagesController < ApplicationController
  def map
    @categories = Category.all

    ## reponse for AJAX call
    if params[:category]
      if params[:category] == 'all'
        render json: Place.all.map(&:geojson)
      else
        render json: Place.tagged_with(params[:category]).map(&:geojson)
      end
    end
  end

  def about
  end
end

class StaticPagesController < ApplicationController
  def map
    @categories = Category.all

    ## reponse for AJAX call
    if params[:category]
      if params[:category] == 'all'
        render json: Place.all.map(&:reviewed_version).compact.map(&:geojson)
      else
        render json: Place.tagged_with(params[:category]).map(&:reviewed_version).map(&:geojson)
      end
    end
  end

  def about
  end
end

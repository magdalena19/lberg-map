class StaticPagesController < ApplicationController
  def map
    @places = Place.all
    @places_json = Place.all.map(&:geojson)
  end

  def about
  end
end

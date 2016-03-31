class StaticPagesController < ApplicationController
  def map
    @places = Place.all
    @placesJson = Place.all.map { |p| p.geojson }
  end

  def about
  end
end

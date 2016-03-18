class StaticPagesController < ApplicationController
  def map
    @places = Place.all
  end

  def about
  end
end

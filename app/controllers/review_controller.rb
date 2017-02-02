class ReviewController < ApplicationController
  before_action :require_login

  def review_index
    @places_to_review = Place.unreviewed_places
    @unreviewed_translations = Place.unreviewed_translations
  end
end

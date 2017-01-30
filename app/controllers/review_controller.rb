class ReviewController < ApplicationController
  before_action :require_login

  def review_index
    @places_to_review = Place.places_to_review
    @unreviewed_translations = Place.all_unreviewed_translations
  end
end

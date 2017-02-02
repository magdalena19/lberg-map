class PlacesReviewController < ApplicationController
  before_action :require_login
  before_action :set_place

  def review
    @reviewed_place = @place.reviewed_version
    @unreviewed_place = @place.unreviewed_version
  end

  def confirm
    if @place.update(reviewed: true) && @place.destroy_all_updates
      flash[:success] = t('.changes_confirmed')
    end
    redirect_to places_review_index_url
  end

  def refuse
    if @place.new? && @place.destroy
      flash[:success] = t('.point_refused')
    elsif @place.versions.last.reify.save && @place.destroy_all_updates(@place)
      flash[:success] = t('.changes_refused')
    end
    redirect_to places_review_index_url
  end

  private

  def set_place
    @place = Place.find(params[:id])
  end
end

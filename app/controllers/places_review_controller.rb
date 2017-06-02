class PlacesReviewController < ApplicationController
  include MapAccessGateway

  before_action :can_access?
  before_action :set_map
  before_action :auth_map, if: :map_password_protected?
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
    @place = @map.places.find(params[:id])
  end
end

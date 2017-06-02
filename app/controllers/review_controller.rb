class ReviewController < ApplicationController
  include MapAccessGateway

  before_action :can_access?
  before_action :set_map
  before_action :auth_map, if: :map_password_protected?

  def review_index
    @places_to_review = @map.unreviewed_places
    @unreviewed_translations = @map.unreviewed_translations
  end

  private

  def set_map
    token = params[:map_token]
    @map = Map.find_by(secret_token: token) || Map.find_by(public_token: token)
  end
end

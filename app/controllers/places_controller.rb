require 'params_modification'
require 'attribute_setter'

class PlacesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  before_action :set_map
  before_action :require_login, only: [:destroy]
  before_action :set_place, only: [:edit, :update, :destroy]
  before_action :can_update?, only: [:update]
  before_action :can_create?, only: [:create]
  before_action :reverse_geocode, only: [:new], if: :supplied_coords?
  before_action :modify_params, only: [:create, :update]

  after_action :store_in_session_cookie, only: [:create, :update]

  def index
    @places = @map.reviewed_places
    unless @current_user.signed_in?
      @places += places_from_session
      @places.uniq
    end
  end

  def edit
    redirect_to map_url(map_token: request[:map_token]) if @place.new?
    @url = place_url(id: @place.id, map_token: request[:map_token])
    flash.now[:warning] = t('.preview_mode') unless @current_user.signed_in?
  end

  def update
    if @params_to_commit.any? && @place.update(@params_to_commit)
      AttributeSetter::Place.set_attributes_after_update(place: @place, params: @params_to_commit, signed_in: @current_user.signed_in?)
      flash[:success] = t('.changes_saved')
      redirect_to map_url(map_token: request[:map_token], latitude: @place.latitude, longitude: @place.longitude)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit, status: 400
    end
  end

  def new
    @place = @map.places.new
    flash.now[:warning] = t('.preview_mode') unless @current_user.signed_in?
  end

  def create
    @place = @map.places.new(@params_to_commit)
    @place.latitude ||= params[:place][:latitude]
    @place.longitude ||= params[:place][:longitude]

    if @place.save
      AttributeSetter::Place.set_attributes_after_create(place: @place, params: @params_to_commit, signed_in: @current_user.signed_in?)
      flash[:success] = t('.created')
      redirect_to map_url(map_token: request[:map_token], latitude: @place.latitude, longitude: @place.longitude)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new, status: 400
    end
  end

  def destroy
    @place.destroy
    flash[:success] = t('.deleted')
    redirect_to places_url(map_token: request[:map_token])
  end

  private

  def modify_params
    @params_to_commit = ParamsModification::Place.modify(place_params: place_params, place: @place)
  end

  def can_update?
    unless can_commit?
      flash.now[:danger] = t('.invalid_captcha')
      @place.assign_attributes(modified_params)
      render :edit
    end
  end

  def can_create?
    unless can_commit?
      flash.now[:danger] = t('.invalid_captcha')
      render :new
    end
  end

  def set_place
    @place = @map.places.find(params[:id])
  end

  def store_in_session_cookie
    if places_from_session.any?
      cookies[:created_places_in_session] += ',' + @place.id.to_s
    else
      cookies[:created_places_in_session] = @place.id.to_s
    end
  end

  # Reverse geocoding
  def supplied_coords?
    params[:longitude] && params[:latitude]
  end

  def reverse_geocode
    require 'place/geocoding'
    query = params[:latitude].to_s + ',' + params[:longitude].to_s
    results = OpenStruct.new Geocoder.search(query).first.data
    @geocoded = PlaceGeocoding.prepare(search_results: results)
  end

  def place_params
    params.require(:place).permit(
      :name,
      :house_number, :street, :postal_code, :district, :city, :federal_state, :country,
      :reviewed,
      :latitude, :longitude,
      *Place.globalize_attribute_names,
      :phone, :homepage, :email,
      :event, :start_date,
      :categories
    )
  end
end

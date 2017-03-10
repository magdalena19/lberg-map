class PlacesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  before_action :require_login, only: [:destroy]
  before_action :set_place, only: [:edit, :update, :destroy]
  before_action :can_update?, only: [:update]
  before_action :can_create?, only: [:create]
  before_action :reverse_geocode, only: [:new], if: :supplied_coords?
  before_action :require_login_if_private_map

  def index
    @places = Place.reviewed_places
    unless @current_user.signed_in?
      @places += places_from_session
      @places.uniq
    end
  end

  def edit
    redirect_to root_url if @place.new?
    flash.now[:warning] = t('.preview_mode') unless @current_user.signed_in?
  end

  def update
    params_to_update ||= PlaceParamsModifier.new(place_params: place_params, place: @place).params
    if params_to_update.any? && @place.update(params_to_update)
      PlaceAttributeSetter.set_attributes_after_update(place: @place, params: params_to_update, signed_in: @current_user.signed_in?)
      store_in_session_cookie
      flash[:success] = t('.changes_saved')
      redirect_to places_url
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit, status: 400
    end
  end

  def new
    @place = Place.new
    flash.now[:warning] = t('.preview_mode') unless @current_user.signed_in?
  end

  def create
    params_to_create ||= PlaceParamsModifier.new(place_params: place_params).params
    @place = Place.new(params_to_create)
    @place.latitude ||= params[:place][:latitude]
    @place.longitude ||= params[:place][:longitude]

    if @place.save
      set_categories
      PlaceAttributeSetter.set_attributes_after_create(place: @place, params: params_to_create, signed_in: @current_user.signed_in?)
      store_in_session_cookie
      flash[:success] = t('.created')
      redirect_to root_url(latitude: @place.latitude, longitude: @place.longitude)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new, status: 400
    end
  end

  def destroy
    @place.destroy
    flash[:success] = t('.deleted')
    redirect_to action: 'index'
  end

  private

  ### CATEGORIES -> factor this out
  def place_categories
    @place.categories.split(/;|,/).map(&:strip)
  end

  def categories_include(category_string:)
    return [] unless Category.any?
    Category.all.select do |category|
      translated_names = category.translations.map(&:name)
      translated_names.include? category_string
    end
  end

  def set_categories
    res = []
    place_categories.each do |category|
      matches = categories_include(category_string: category)
      if matches.any?
        res << matches.map(&:id)
      else
        new_category = Category.create name: category
        res << new_category.id
      end
    end

    @place.without_versioning do
      @place.update_attributes(categories: res.join(','))
    end
  end

  def can_commit?
    simple_captcha_valid? || @current_user.signed_in?
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
    @place = Place.find(params[:id])
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
      :categories
    )
  end
end

class PlacesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers
  before_action :require_login, only: [:destroy]
  before_action :set_place, only: [:edit, :update, :destroy]
  before_action :reverse_geocode, only: [:new], if: :supplied_coords?

  def index
    @places = Place.reviewed
    unless signed_in?
      @places += places_from_session
      @places.uniq
    end
  end

  def edit
    redirect_to root_url if @place.new?
    flash.now[:warning] = t('.preview_mode') unless signed_in?
  end

  def update
    if simple_captcha_valid? || signed_in?
      save_update
    else
      flash.now[:danger] = t('.invalid_captcha')
      @place.assign_attributes(modified_params)
      render :edit
    end
  end

  def new
    @place = Place.new
    flash.now[:warning] = t('.preview_mode') unless signed_in?
  end

  def create
    @place = Place.new(modified_params)
    @place.latitude ||= params[:place][:latitude]
    @place.longitude ||= params[:place][:longitude]

    if simple_captcha_valid? || signed_in?
      save_new
    else
      flash.now[:danger] = t('.invalid_captcha')
      render :new
    end
  end

  def destroy
    @place.destroy
    flash[:success] = t('.deleted')
    redirect_to action: 'index'
  end

  private

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

  # Conditionally inject values into place_params
  def modified_params
    modified_params ||= place_params
    if place_params[:categories]
      category_param = place_params[:categories].sort || []
      modified_params[:categories] = category_param.reject(&:empty?).join(',')
    end
    if @place && @place.lat_lon_present?
      modified_params[:latitude] = @place.latitude
      modified_params[:longitude] = @place.longitude
    end
    modified_params
  end

  def place_params
    params.require(:place).permit(
      :name, :street, :house_number, :postal_code, :city,
      :reviewed,
      *Place.globalize_attribute_names,
      :phone, :homepage, :email,
      categories: []
    )
  end

  # Reverse geocoding
  def supplied_coords?
    params[:longitude] && params[:latitude]
  end

  def reverse_geocode
    query = params[:latitude].to_s + ',' + params[:longitude].to_s
    @geocoded = Geocoder.search(query).first.data['address']
  end

  # Find if params hash contains translation related key
  def globalized_params
    params[:place].keys.select do |key, _value|
      Place.globalize_attribute_names.include? key.to_sym
    end
  end

  def locales_from_place_params
    globalized_params.map { |param| param.split('_').last }.flatten.select(&:present?)
  end

  # Update reviewed flags depending on login status
  def update_place_reviewed_flag
    @place.without_versioning do
      @place.update!(reviewed: signed_in?)
    end
  end

  def update_translations_reviewed_flag
    locales_from_place_params.each do |locale|
      translation = @place.translations.find_by_locale(locale)
      @place.destroy_all_updates(translation) if signed_in?
      translation.without_versioning do
        translation.update(reviewed: signed_in?)
      end
    end
  end

  # Set reviewed flags depending on login status during creation
  def set_inital_reviewed_flags
    update_place_reviewed_flag
    @place.destroy_all_updates
    @place.translations.each do |translation|
      translation.without_versioning do
        translation.update!(reviewed: signed_in?)
      end
    end
  end

  def save_update
    length_before_update = @place.versions.length

    if @place.update(modified_params)
      store_in_session_cookie
      flash[:success] = t('.changes_saved')
      @place.destroy_all_updates if signed_in?

      # TODO Something brownish happening here... reviewed flag not set to false!
      update_translations_reviewed_flag if globalized_params.any?
      redirect_to places_url
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit, status: 400
    end

    length_after_update = @place.versions.length
    update_place_reviewed_flag if length_before_update != length_after_update
  end

  def save_new
    if @place.save
      store_in_session_cookie
      set_inital_reviewed_flags
      flash[:success] = t('.created')
      redirect_to root_url(latitude: @place.latitude, longitude: @place.longitude)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new, status: 400
    end
  end
end

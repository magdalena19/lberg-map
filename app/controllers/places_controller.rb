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
    filtered_params = modified_params
    if filtered_params.any? && @place.update(filtered_params)
      PlaceAttributeSetter.set_attributes_after_update(place: @place, params: filtered_params, signed_in: @current_user.signed_in?)
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
    filtered_params = modified_params
    @place = Place.new(filtered_params)
    @place.latitude ||= params[:place][:latitude]
    @place.longitude ||= params[:place][:longitude]

    if @place.save
      PlaceAttributeSetter.set_attributes_after_create(place: @place, params: filtered_params, signed_in: @current_user.signed_in?)
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

  def globalized_params
    place_params.keys.select do |key, _value|
      Place.globalize_attribute_names.include? key.to_sym
    end
  end

  def locales_from_place_params
    globalized_params.map { |param| param.split('_').last }.flatten.select(&:present?)
  end

  def translations_from_place_params
    locales_from_place_params.map do |locale|
      @place.translations.find_by(locale: locale)
    end
  end

  def update_translation_attributes?(translation)
    place_params.keys.include? "description_#{translation.locale.to_s}"
  end

  def update_place_attributes?
    place_params.except(*globalized_params).any?
  end

  # Conditionally inject values into place_params
  def modified_params
    parameters = place_params
    if @place.present?
      if update_place_attributes? && !@place.reviewed
        parameters.except!(*Place.column_names)
        flash[:danger] = t('.locked_until_reviewed')
      end

      translations_from_place_params.each do |t|
        if update_translation_attributes?(t) && !t.reviewed
          parameters.except!("description_#{t.locale.to_s}")
          flash[:danger] = t('.locked_until_reviewed')
        end
      end
    end

    if place_params[:categories]
      category_param = place_params[:categories].sort || []
      parameters[:categories] = category_param.reject(&:empty?).join(',')
    end

    if @place && @place.lat_lon_present?
      parameters[:latitude] = @place.latitude
      parameters[:longitude] = @place.longitude
    end
    parameters
  end

  def place_params
    params.require(:place).permit(
      :name, :street, :house_number, :postal_code, :city,
      :reviewed,
      :latitude, :longitude,
      *Place.globalize_attribute_names,
      :phone, :homepage, :email,
      categories: []
    )
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
    query = params[:latitude].to_s + ',' + params[:longitude].to_s
    @geocoded = Geocoder.search(query).first.data['address']
  end
end

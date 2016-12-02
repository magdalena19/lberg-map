class PlacesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers
  before_action :require_login, only: [:destroy]
  before_action :reviewed?, only: [:update]

  def index
    @places = Place.reviewed
    unless signed_in?
      @places -= Place.where(id: places_from_session.map(&:id))
      @places += places_from_session
      @places.uniq
    end
  end

  def edit
    @place = Place.find(params[:id])
    redirect_to root_url if @place.new?
    flash.now[:warning] = t('.preview_mode') unless signed_in?
  end

  def update
    @place = Place.find(params[:id])
    if simple_captcha_valid? || signed_in?
      save_update
    else
      flash.now[:danger] = t('.invalid_captcha')
      @place.assign_attributes(modified_params)
      render :edit
    end
  end

  def new
    if params[:longitude] && params[:latitude]
      query = params[:latitude].to_s + ',' + params[:longitude].to_s
      @geocoded = Geocoder.search(query).first.data['address']
    end
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
    @place = Place.find(params[:id])
    @place.destroy
    flash[:success] = t('.deleted')
    redirect_to action: 'index'
  end

  private

  def save_in_cookie
    if !cookies[:created_places_in_session]
      cookies[:created_places_in_session] = @place.id.to_s
    else
      cookies[:created_places_in_session] = cookies[:created_places_in_session] + ',' + @place.id.to_s
    end
  end

  def places_from_session(category_id = nil)
    ids = cookies[:created_places_in_session]
    array = ids ? ids.split(',') : []
    if category_id
      Place.where(id: array).compact.find_all { |p| p.has_category?(category_id) }
    else
      Place.where(id: array)
    end
  end

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
      :description, *Place.globalize_attribute_names,
      :phone, :homepage, :email,
      categories: []
    )
  end

  def globalized_params
    params[:place].keys.select do |key, _value|
      Place.globalize_attribute_names.include? key.to_sym
    end
  end

  def locales_from_place_params
    globalized_params.map { |param| param.split('_').last }.flatten.select(&:present?)
  end

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

  def initialize_reviewed_flags
    update_place_reviewed_flag
    @place.destroy_all_updates
    @place.translations.each do |translation|
      translation.without_versioning do
        translation.update!(reviewed: signed_in?)
      end
    end
  end

  def reviewed?
    Place.find(params[:id]).reviewed
  end

  def save_update
    length_before_update = @place.versions.length

    if @place.update(modified_params)
      save_in_cookie
      flash[:success] = t('.changes_saved')
      @place.destroy_all_updates if signed_in?
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
      save_in_cookie
      initialize_reviewed_flags
      flash[:success] = t('.created')
      redirect_to root_url(latitude: @place.latitude, longitude: @place.longitude)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new, status: 400
    end
  end

  def require_login
    unless session[:user_id]
      flash[:danger] = t('errors.messages.access_restricted')
      redirect_to login_url
    end
  end
end

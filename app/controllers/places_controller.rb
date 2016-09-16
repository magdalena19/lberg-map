class PlacesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  def index
    return @places = Place.all if signed_in?
    if params[:category]
      @places = (Place.with_reviewed_category(params[:category]) + places_from_session(params[:category])).uniq
    else
      @places = (Place.reviewed + places_from_session(nil)).uniq
    end
  end

  def edit
    @place = Place.find(params[:id])
    redirect_to root_url if @place.new?
    flash.now[:warning] = t('.preview_mode') unless signed_in?
  end

  def update
    @place = Place.find(params[:id])
    @place.reviewed = true if signed_in?
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
    @place.reviewed = true if signed_in?
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

  def places_from_session(category_id)
    ids = cookies[:created_places_in_session]
    array = ids ? ids.split(',') : []
    if category_id
      Place.where(id: array).compact.find_all { |p| p.has_category?(category_id) }
    else
      Place.where(id: array)
    end
  end

  def save_update
    # Ugly: lat/lon have to be inserted into modified_params-hash in order to make update_attributes work...
    params_for_update = modified_params
    if @place.lat_lon_present?
      params_for_update[:latitude] = @place.latitude
      params_for_update[:longitude] = @place.longitude
    end
    if @place.update_attributes(params_for_update)
      flash[:success] = t('.changes_saved')
      redirect_to places_path
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit
    end
  end

  def save_new
    # Take lat/lon values from hash passed by create form
    @place.latitude ||= params[:place][:latitude]
    @place.longitude ||= params[:place][:longitude]
    if @place.save
      save_in_cookie
      flash[:success] = t('.created')
      redirect_to root_url(latitude: @place.latitude, longitude: @place.longitude)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new
    end
  end

  def save_in_cookie
    if !cookies[:created_places_in_session]
      cookies[:created_places_in_session] = @place.id.to_s
    else
      cookies[:created_places_in_session] = cookies[:created_places_in_session] + ',' + @place.id.to_s
    end
  end

  def modified_params
    modified_params ||= place_params
    if place_params[:categories]
      category_param = place_params[:categories] || []
      modified_params[:categories] = category_param.reject(&:empty?).join(',')
    end
    modified_params
  end

  def place_params
    params.require(:place).permit(
      :name, :street, :house_number, :postal_code, :city,
      :description_en, :description_de, :description_fr, :description_ar, :reviewed,
      :latitude, :longitude,
      :phone, :homepage, :email,
      categories: []
    )
  end
end

class PlacesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  def index 
    if params[:category]
      @places = Place.with_reviewed_category(params[:category]) + places_from_session(params[:category])
    else
      @places = Place.reviewed + places_from_session(nil)
    end
  end

  def edit
    @place = Place.find(params[:id])
    redirect_to root_path if @place.new?
    flash.now[:warning] = 'You are currently in preview mode, changes you make have
    to be reviewed before they become published!' unless signed_in?
  end

  def update
    @place = Place.find(params[:id])
    @place.reviewed = true if signed_in?
    if simple_captcha_valid? || signed_in?
      save_update
    else
      flash.now[:danger] = 'Captcha not valid!'
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
    flash.now[:warning] = 'You are currently in preview mode, changes you make have
    to be reviewed before they become published!' unless signed_in?
  end

  def create
    @place = Place.new(modified_params)
    @place.reviewed = true if signed_in?
    if simple_captcha_valid? || signed_in?
      save_new
    else
      flash.now[:danger] = 'Captcha not valid!'
      render :new
    end
  end

  def destroy
    @place = Place.find(params[:id])
    @place.destroy
    redirect_to action: 'index'
  end

  private

  def places_from_session(category_id)
    ids = cookies[:created_places_in_session]
    array = ids ? ids.split(',') : []
    if category_id
      Place.where(id: array ).compact.find_all { |p| p.has_category?(category_id) }
    else
      Place.where(id: array )
    end
  end

  def save_update
    if @place.update_attributes(modified_params)
      flash[:success] = 'Changes saved! Wait for review...'
      redirect_to places_path
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit
    end
  end

  def save_new
    @place.latitude ||= params[:place][:latitude]
    @place.longitude ||= params[:place][:longitude]
    if @place.save
      if !cookies[:created_places_in_session]
        cookies[:created_places_in_session] = @place.id.to_s
      else
        cookies[:created_places_in_session] = cookies[:created_places_in_session] + ',' + @place.id.to_s
      end
      redirect_to root_path(latitude: @place.latitude, longitude: @place.longitude)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new
    end
  end

  def modified_params
    modified_params ||= place_params
    if place_params[:categories]
      category_param = place_params[:categories] || []
      modified_params[:categories] = category_param.reject(&:empty?).join(',')
    end
    place_params[:categories]
    modified_params
  end

  def place_params
    params.require(:place).permit(
    :name, :street, :house_number, :postal_code, :city,
    :description_en, :description_de, :description_fr, :description_ar, :reviewed,
    :latitude, :longitude,
    categories: []
    )
  end
end

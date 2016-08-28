class PlacesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  def index
    return @places = Place.reviewed unless params[:category]
    @places = Place.with_reviewed_category(params[:category])
  end

  def edit
    @place = Place.find(params[:id])
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
    if @place.save
      flash[:success] = 'Point successfully created!'
      redirect_to action: 'index'
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
    categories: []
    )
  end
end

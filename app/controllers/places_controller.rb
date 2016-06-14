class PlacesController < ApplicationController
  # http_basic_authenticate_with name: 'admin', password: 'secret'
  include SimpleCaptcha::ControllerHelpers
  before_action :require_login, only: [:review]

  def index
    if params[:category]
      @places = Place.tagged_with(params[:category])
    else
      @places = Place.all
    end
  end

  def edit
    @place = Place.find(params[:id])
    flash.now[:warning] = 'You are currently in preview mode, changes you make have to be reviewed before they
    become published!' unless signed_in?
  end

  def review
    @places = Place.where(reviewed: false).order('updated_at DESC').paginate(page: params[:page], per_page: 15)
  end

  def update
    @place = Place.find(params[:id])
    @place.reviewed = true if signed_in?
    if simple_captcha_valid? || signed_in?
      save_update
    else
      flash.now[:danger] = t('captcha_invalid', scope: :flash_messages)
      render :edit
    end
  end

  def new
    if params[:longitude] && params[:latitude]
      query = params[:latitude].to_s + ',' + params[:longitude].to_s
      @geocoded = Geocoder.search(query).first.data['address']
    end
    @place = Place.new
    flash.now[:warning] = 'You are currently in preview mode, changes you make have to be reviewed before they
    become published!' unless signed_in?
  end

  def create
    @place = Place.new(place_params)
    @place.reviewed = true if signed_in?
    if simple_captcha_valid? || signed_in?
      save_new
    else
      flash.now[:danger] = t('captcha_invalid', scope: :flash_messages)
      render :new
    end
  end

  def destroy
    @place = Place.find(params[:id])
    @place.categorizings.destroy_all
    @place.destroy
    redirect_to action: 'index'
  end

  private

  def save_update
    if @place.update_attributes(place_params)
      flash.now[:success] = t('point_changed', scope: :flash_messages)
      redirect_to places_path
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit
    end
  end

  def save_new
    if @place.save
      flash[:success] = t('point_created', scope: :flash_messages)
      redirect_to action: 'index'
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new
    end
  end

  def place_params
    params.require(:place).permit(
    :name, :street, :house_number, :postal_code, :city,
    :description_en, :description_de, :description_fr, :description_ar,
    category_ids: []
    )
  end

  def require_login
    unless signed_in?
      flash.now[:danger] = 'Access to this page has been restricted. Please login first!'
      redirect_to login_path
    end
  end
end

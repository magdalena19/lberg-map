class PlacesController < ApplicationController
  # http_basic_authenticate_with name: 'admin', password: 'secret'

  def index
    @places = Place.all
    @errors = []
  end

  def edit
    @place = Place.find(params[:id])
  end

  def update
    @place = Place.find(params[:id])
    if @place.update_attributes(place_params)
      flash.now[:success] = 'Point successfully changed!'
      redirect_to places_path
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit
    end
  end

  def new
    if params[:longitude] && params[:latitude]
      query = params[:latitude].to_s + ',' + params[:longitude].to_s
      @geocoded = Geocoder.search(query).first.data['address']
    end
    @place = Place.new
    @place.descriptions.build
  end

  def create
    @place = Place.new(place_params)
    if @place.save
      flash[:success] = 'Point successfully created!'
      redirect_to action: 'index'
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new
    end
  end

  def destroy
    @place = Place.find(params[:id])
    @place.destroy
    redirect_to action: 'index'
  end

  private

  def place_params
    params.require(:place).permit(:name, :street, :house_number, :postal_code, :city, :all_categories, descriptions_attributes: [:id, :language, :text])
  end
end

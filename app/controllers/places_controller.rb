class PlacesController < ApplicationController
  http_basic_authenticate_with name: 'admin', password: 'secret'

  def index
    @places = Place.all
    @errors = []
  end

  def update
    @place = Place.find(params[:id])
    @place.update(place_params)
    @errors = @place.errors

    redirect_to action: 'index'
  end

  def new
    @place = Place.new
    @place.descriptions.build
  end

  def create
    @place = Place.new(place_params)
    @place.save
    @errors = @place.errors

    redirect_to action: 'index'
  end

  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    redirect_to action: 'index'
  end

  private

  def place_params
    params.require(:place).permit(:name, :latitude, :longitude, :categories, descriptions_attributes: [:id, :language, :text])
  end
end

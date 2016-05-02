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
      flash[:success] = 'Changes successful!'
      redirect_to places_path
    else
      @errors = @place.errors
      render :edit
    end
  end

  def new
    @place = Place.new
    @place.descriptions.build
  end

  def create
    @place = Place.new(place_params)
    if @place.save
      flash[:danger] = ''
      redirect_to action: 'index'
    else
      @errors = @place.errors
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
    params.require(:place).permit(:name, :street, :house_number, :postal_code, :city, :latitude, :longitude, :categories, descriptions_attributes: [:id, :language, :text])
  end
end

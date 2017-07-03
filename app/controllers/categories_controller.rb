class CategoriesController < ApplicationController
  before_action :set_map
  before_action :set_category, only: [:update, :destroy]
  after_action :update_category_strings, only: %i[update destroy]

  respond_to :js

  def index
    render json: @map.categories.map(&:to_json), status: 200
  end

  def create
    if @category = @map.categories.create(category_params)
      render json: @category.to_json
    else
      render json: @category.errors.full_messages, status: unprocessable_entity
    end
  end

  def update
    if @category.update_attributes(category_params)
      render json: @category.to_json
    else
      render json: @category.errors.full_messages, status: unprocessable_entity
    end
  end

  def destroy
    render nothing: true, status: 200 if @category.destroy
  end

  private

  def set_map
    @map = Map.find_by(secret_token: request[:map_token])
  end

  def category_params
    params.require(:category).permit(
      *Category.globalize_attribute_names
    )
  end

  def set_category
    @category = Category.find(params[:id])
    @places = Place.find(@category.places.pluck(:id))
  end

  # Update category string
  def update_category_strings
    @places.each do |place|
      new_categories_string = place.categories.map(&:name).join(', ')
      place.update_attributes(categories_string: new_categories_string)
    end
  end
end

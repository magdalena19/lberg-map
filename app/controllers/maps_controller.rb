class MapsController < ApplicationController
  before_action :set_map

  def show
    @categories = @map.categories.all
    @last_places_created = last_places_created
    @latitude = params[:latitude]
    @longitude = params[:longitude]
    @places_to_show = places_to_show

    respond_to do |format|
      format.json { render json: places_to_show.map(&:geojson), status: 200 }
      format.html
    end
  end

  def index
    @maps = @current_user.maps
  end

  def new
    @map = Map.new
    @url = new_map_url
  end

  def create
    @map = Map.new(map_params)
    if @map.save
      flash.now[:success] = 'New map created!'
      redirect_to map_path(@map.secret_token)
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new, status: 400
    end
  end

  def edit
    @url = map_url(id: @map.id)
  end

  def update
    if @map.update_attributes(map_params)
      flash[:success] = t('.changes_saved')
      redirect_to places_url
    else
      flash.now[:danger] = @map.errors.full_messages.to_sentence
      render :edit, status: 400
    end
  end

  def chronicle
    @announcements = @map.announcements.all.sort_by(&:created_at).reverse
  end

  private

  def places_to_show
    (@map.reviewed_places + places_from_session).uniq
  end

  def last_places_created
    places_to_show.sort_by(&:created_at).last(5)
  end

  def map_params
    params.require(:map).permit(
      :title,
      :description,
      :maintainer_email_address,
      :imprint,
      :is_public,
      :public_token,
      :secret_token,
      :allow_guest_commits,
      :auto_translate,
      :translation_engine
    )
  end
end

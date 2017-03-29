class MapsController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  before_action :set_map, except: [:new, :index]
  before_action :is_signed_in?, only: [:index]
  before_action :can_create?, only: [:create]

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
    @url = { action: :create, controller: :maps } # Specify this so map form does commit to correct route...
  end

  def create
    @map = Map.new(map_params)
    @map.user = @current_user unless @current_user.guest?

    if @map.save
      flash[:success] = t('.created')
      redirect_to map_path(@map.secret_token)
    else
      flash.now[:danger] = @map.errors.full_messages.to_sentence
      render :new, status: 400
    end
  end

  def edit
  end

  def update
    if @map.update_attributes(map_params)
      flash[:success] = t('.changes_saved')
      redirect_to maps_url
    else
      flash.now[:danger] = @map.errors.full_messages.to_sentence
      render :edit, status: 400
    end
  end

  def destroy
    @map.destroy
    flash[:warning] = t('.deleted')
    redirect_to maps_url
  end

  def chronicle
    @announcements = @map.announcements.all.sort_by(&:created_at).reverse
  end

  def share_map
  end

  def send_invitations
    guests_mail_addresses = params[:guests] ? params[:guests].split(/,|;|\s/).delete_if(&:empty?) : []
    collaborators_mail_addresses = params[:collaborators] ? params[:collaborators].split(/,|;|\s/).delete_if(&:empty?) : []

    guests_mail_addresses.each do |mail_address|
      send_invitation(token: @map.public_token, email_address: mail_address)
    end

    collaborators_mail_addresses.each do |mail_address|
      send_invitation(token: @map.secret_token, email_address: mail_address)
    end

    flash[:success] = t('.invitations_sent') if guests_mail_addresses.any? || collaborators_mail_addresses.any?
    redirect_to map_path(map_token: @map.secret_token)
  end

  private

  def send_invitation(token:, email_address:)
    MapInvitationWorker.perform_async(map_token: token, email_address: email_address)
  end

  def is_signed_in?
    return true unless @current_user.guest?
    flash[:error] = t('.need_to_register')
    redirect_to landing_page_url
  end

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
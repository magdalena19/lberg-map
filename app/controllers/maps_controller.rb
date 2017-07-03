class MapsController < ApplicationController
  include SimpleCaptcha::ControllerHelpers
  include Recaptcha::Verify
  include MapAccessGateway # Includes authentication and access restriction methods

  before_action :set_map, except: [:new, :index]
  before_action :allow_iframe_request, only: [:show_embedded, :show]
  before_action :auth_map, if: :needs_to_be_unlocked?, only: [:update, :destroy, :edit, :share_map, :send_invitations]
  before_action :unset_password_if_unchecked, only: [:update]

  # Ressources for map unlocking maps via password
  # Return true/false server-side if map is password protected and has not been unlocked yet
  def needs_unlock
    respond_to do |format|
      format.json { render json: { needs_unlock: needs_to_be_unlocked? }.to_json, status: 200 }
    end
  end

  # Unlock server-side, i.e. accept password and add map token to session hash if auth success
  def unlock
    authenticated = @map.authenticated?(attribute: 'password', token: params[:password])
    session[:unlocked_maps].append(request[:map_token]).uniq! if authenticated

    respond_to do |format|
      format.js do
        if unlocked?
          render nothing: true, status: 200
        else
          render nothing: true, status: 401
        end
      end
    end
  end

  # HTTP response does not need to be authenticated as it renders only the template
  # ajax calls 
  def show
    @categories = @map.categories.all
    @latitude = params[:latitude]
    @longitude = params[:longitude]
    @places_to_show = places_to_show
    @events_to_show = @places_to_show.select(&:event)
    @static_places_to_show= @places_to_show.select { |p| !p.event }

    respond_to do |format|
      format.json do
        if unlocked?
          render json: places_to_show.map(&:geojson), status: 200
        else
          render nothing: true, status: 401
        end
      end
      format.html do
        if params[:iframe] == 'true'
          render layout: 'iframe' 
        else
          render layout: 'application'
        end
      end
    end
  end

  def index
    if @current_user.signed_in?
      @maps = @current_user.maps
    elsif session[:maps].any?
      @maps = session[:maps].map { |id| Map.find(id) }
    else
      redirect_to landing_page_path
    end
  end

  def new
    @map = Map.new
    @url = { action: :create, controller: :maps } # Specify this so map form does commit to correct route...
  end

  def create
    @map = Map.new(map_params)
    @map.user = @current_user unless @current_user.guest?

    if can_commit?(model: @map) && @map.save
      session[:maps] << @map.id if @current_user.guest?
      flash[:success] = t('.created')
      redirect_to map_path(@map.secret_token)
    else
      flash.now[:danger] = @map.errors.full_messages.to_sentence
      render :new, status: 400
    end
  end

  def edit
    @url = { action: :update, controller: :maps, map_token: @map.secret_token } # Specify this so map form does commit to correct route...
  end

  def update
    if can_commit?(model: @map) && @map.update_attributes(map_params)
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
    respond_to do |format|
      format.js do
        map_guests_mail_addresses = params[:map_guests] ? params[:map_guests].split(/,|;|\s/).delete_if(&:empty?) : []
        map_admin_mail_addresses = params[:map_admins] ? params[:map_admins].split(/,|;|\s/).delete_if(&:empty?) : []

        map_guests_mail_addresses.each do |email_address|
          send_invitation(receiver: 'guest', email_address: email_address, id: params[:id])
        end

        map_admin_mail_addresses.each do |email_address|
          send_invitation(receiver: 'admin', email_address: email_address, id: params[:id])
        end

        flash.now[:success] = t('.invitations_sent')
        render nothing: true, status: 200
      end
    end
  end

  private

  def allow_iframe_request
    response.headers.delete('X-Frame-Options')
  end

  def unset_password_if_unchecked
    @map.update_attributes(password_digest: nil) unless params[:map][:password_protect].present?
  end

  def is_public_token?
    Map.pluck(:public_token).include?(request[:map_token])
  end

  def unlocked?
    is_public_token? ||
      !@map.password_protected? || 
      session[:unlocked_maps].include?(request[:map_token])
  end

  def places_to_show
    (@map.reviewed_places + @map.reviewed_events + items_from_session).uniq
  end

  def send_invitation(receiver:, email_address:, id:)
    MapInvitationWorker.perform_async(receiver, email_address, id)
  end

  def is_signed_in?
    return true unless @current_user.guest?
    flash[:error] = t('.need_to_register')
    redirect_to landing_page_url
  end

  def map_params
    # Modify params auto_translate flag according to chosen translation engine
    params[:map]['auto_translate'] = params[:map]['translation_engine'] == 'none' ? false : true

    # White-list params
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
      :password,
      :password_confirmation,
      :translation_engine,
      supported_languages: []
    )
  end
end

require 'guest_user'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :prepare_session
  helper_method :current_user

  def prepare_session
    set_locale
    session[:maps] ||= []
    session[:places] ||= []
  end

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      @local_not_selected = true
    end
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def set_map
    token = params[:map_token]
    @map = Map.find_by(secret_token: token) || Map.find_by(public_token: token)
  end

  # User and login related stuff
  def owns_map
    current_user == @map.user
  end

  def map_access_via_secret_link
    set_map
    @map && @map.secret_token == request[:map_token]
  end

  def current_user
    @current_user ||= if user = User.find_by(id: session[:user_id])
                        user
                      elsif map_access_via_secret_link
                        PrivilegedGuestUser.new
                      else
                        GuestUser.new
                      end
  end

  def has_privileged_map_access
    set_map
    map_access_via_secret_link || owns_map
  end

  def require_login
    if @current_user.guest?
      flash[:danger] = t('errors.messages.access_restricted')
      redirect_to login_url
    end
  end

  def can_commit?
    simple_captcha_valid? || @current_user.signed_in?
  end

  def can_create?
    unless can_commit?
      flash.now[:danger] = t('simple_captcha.captcha_invalid')
      render :new
    end
  end

  def places_from_session(category_id = nil)
    if category_id
      @map.places.where(id: session[:places]).compact.find_all { |p| p.category_for(category_id) }
    else
      @map.places.where(id: session[:places])
    end
  end
end

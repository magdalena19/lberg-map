module MapAccessGateway
  extend ActiveSupport::Concern
  attr_accessor :model

  included do
    helper_method :set_map
    helper_method :auth_map
    helper_method :needs_to_be_unlocked?
    helper_method :can_access?
    helper_method :map_access_via_secret_link
    helper_method :require_login
    helper_method :current_user
    helper_method :can_commit?
  end

  def set_map
    token = params[:map_token]
    return nil if token.nil?
    @map = Map.find_by(secret_token: token) || Map.find_by(public_token: token)
  end

  # AUTHENTICATION
  def map_access_via_secret_link
    set_map
    @map && @map.secret_token == token
  end

  def auth_map
    redirect_to map_path(map_token: token ) unless session[:unlocked_maps].include? token
  end

  def map_in_session_cache
    session[:unlocked_maps].include?(params[:map_token])
  end

  def needs_to_be_unlocked?
    set_map
    map_access_via_secret_link && @map.password_protected? && !map_in_session_cache
  end
  
  # CAPTCHA
  def captcha_valid?
    if Admin::Setting.captcha_system == 'recaptcha'
      return verify_recaptcha(model: @model)
    else
      return simple_captcha_valid?
    end
  end

  # ACCESS RIGHTS
  def can_access?
    render nothing: true, status: 401 unless map_access_via_secret_link
  end

  def can_commit_to?(model:)
    @model = model
    @current_user.signed_in? || captcha_valid?
  end

  def owns_map
    set_map
    current_user == @map.user
  end

  def has_privileged_map_access
    set_map
    map_access_via_secret_link || owns_map
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

  def require_login
    if @current_user.guest?
      flash[:danger] = t('errors.messages.access_restricted')
      redirect_to login_url
    end
  end

  private

  def token
    request[:map_token]
  end
end

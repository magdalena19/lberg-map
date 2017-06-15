class Admin::SettingsController < AdminController
  before_action :init_settings, only: [:edit, :update]

  def edit
    @settings_hash = Admin::Setting.all_settings
  end

  def update
    if @settings.update_attributes(settings_params)
      flash[:success] = t('.success')
      redirect_to admin_settings_url
    else
      flash[:success] = t('.errors')
      render :edit
    end
  end

  def captcha_system_status
    respond_to do |format|
      format.json { render json: check_captcha_system(captcha_system: params[:captcha_system]).to_json, status: 200 }
    end
  end

  private

  def check_captcha_system(captcha_system:)
    case captcha_system
    when 'recaptcha'
      return recaptcha_status
    when 'simple_captcha'
      return simple_captcha_status
    end
  end

  def recaptcha_status
    if ENV['RECAPTCHA_SITE_KEY'] && ENV['RECAPTCHA_SECRET_KEY']
      { status_code: 'working', status_message: t('.captcha_system_working') }
    else
      { status_code: 'error', status_message: t('.no_valid_api_key') }
    end
  end

  def simple_captcha_status
    return { status_code: 'working', status_message: t('.captcha_system_working') }
  end

  def settings_params
    params.require(:admin_setting).permit(
      :app_title,
      :admin_email_address,
      :user_activation_tokens,
      :captcha_system,
      :app_imprint,
      :app_privacy_policy
    )

  end

  def init_settings
    @settings = Admin::Setting.last || Admin::Setting.create
  end
end

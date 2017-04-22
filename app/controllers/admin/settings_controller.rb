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

  private

  def settings_params
    params.require(:admin_setting).permit(:app_title, :admin_email_address, :user_activation_tokens)
  end

  def init_settings
    @settings = Admin::Setting.last || Admin::Setting.create
  end
end

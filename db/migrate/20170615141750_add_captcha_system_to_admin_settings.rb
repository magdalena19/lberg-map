class AddCaptchaSystemToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :captcha_system, :string, default: 'recaptcha'
  end
end

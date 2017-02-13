class Admin::SettingsController < ApplicationController
  before_action :is_admin?

  def index
    @settings = Admin::Setting.all
  end

  private

  def is_admin?
    redirect_to root_path unless @current_user.admin?
  end
end

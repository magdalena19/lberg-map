class Admin::DashboardController < ApplicationController
  before_action :is_admin?
  def index
  end

  private

  def is_admin?
    redirect_to root_path unless @current_user.admin?
  end
end

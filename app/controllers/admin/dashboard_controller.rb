class Admin::DashboardController < ApplicationController
  before_action :require_admin_privileges

  def index
  end
end

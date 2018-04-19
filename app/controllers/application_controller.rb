require 'guest_user'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include MapAccessGateway

  before_action :prepare_session

  def prepare_session
    set_locale
    session[:maps] ||= []
    session[:places] ||= []
    session[:unlocked_maps] ||= []
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

  def items_from_session
    @map.places.where(id: session[:places])
  end
end

class StaticPagesController < ApplicationController
  def choose_locale
    redirect_to landing_page_url if session[:locale]
  end

  def landing_page
    session[:locale] = locale
  end
end

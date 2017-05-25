class SessionsController < ApplicationController
  def create
    @user = User.find_by_email(params[:sessions][:email])

    if @user && @user.authenticate(params[:sessions][:password])
      session[:user_id] = @user.id
      redirect_to root_url
    else
      flash[:danger] = t('.login_error')
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end

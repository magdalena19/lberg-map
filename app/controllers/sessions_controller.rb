class SessionsController < ApplicationController
  def create
    @user = User.find_by_email(params[:sessions][:email])

    if @user && @user.authenticate(params[:sessions][:password])
      session[:user_id] = @user.id
      flash.now[:success] = t('welcome_user', scope: :flash_messages)
      redirect_to root_path
    else
      flash.now[:danger] = t('login_error', scope: :flash_messages)
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end

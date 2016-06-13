class SessionsController < ApplicationController
  def create
    @user = User.find_by_email(params[:sessions][:email])

    if @user && @user.authenticate(params[:sessions][:password])
      session[:user_id] = @user.id
      flash.now[:success] = "Welcome #{@user.name}!"
      redirect_to root_path
    else
      flash.now[:danger] = 'Username and password do not match!'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end

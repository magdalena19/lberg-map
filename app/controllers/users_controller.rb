class UsersController < ApplicationController
  before_action :require_authentication
  before_action :require_to_be_same_user

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash.now[:success] = 'Successfully changed user credentials'
      redirect_to root_path
    else
      flash.now[:danger] = 'Changes could not be submitted'
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def require_to_be_same_user
    user_to_be_edited = User.find(url_options[:_recall][:id])
    unless user_to_be_edited.id == session[:user_id]
      flash.now[:danger] = 'Cannot change credentials of another user!'
      redirect_to root_path
    end
  end

  def require_authentication
    unless session[:user_id]
      flash.now[:danger] = 'Access to this page has been restricted. Please login first!'
      redirect_to login_path
    end
  end
end

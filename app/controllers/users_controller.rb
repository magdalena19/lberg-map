class UsersController < ApplicationController
  before_action :require_authentication
  before_action :require_to_be_same_user

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash.now[:success] = t('changes_successful', scope: :flash_messages)
      redirect_to root_path
    else
      flash.now[:danger] = @user.errors.full_messages.to_sentence
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
      flash.now[:danger] = t('cannot_change_other_users_creds', scope: :flash_messages)
      redirect_to root_path
    end
  end

  def require_authentication
    unless session[:user_id]
      flash.now[:danger] = t('access_restricted', scope: :flash_messages)
      redirect_to login_path
    end
  end
end

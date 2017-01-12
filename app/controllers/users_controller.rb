class UsersController < ApplicationController
  before_action :require_login
  before_action :require_to_be_same_user

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = t('.changes_saved')
      redirect_to root_url
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
    redirect_to root_url unless user_to_be_edited.id == current_user.id
  end
end

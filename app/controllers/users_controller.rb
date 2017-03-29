class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  before_action :require_to_be_same_user, only: [:edit, :update]

  def sign_up
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    token = ActivationToken.find_by(token: params[:activation_token])

    if token && @user.save
      token.invalidate
      WelcomeUserWorker.perform_async(@user.id)
      flash[:success] = t('.changes_saved')
      redirect_to maps_path
    else
      flash.now[:danger] = @user.errors.full_messages.to_sentence
      render :sign_up, status: 403
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = t('.changes_saved')
      redirect_to edit_user_path(@user)
    else
      flash.now[:danger] = @user.errors.full_messages.to_sentence
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :activation_token)
  end

  def require_to_be_same_user
    user_to_be_edited = User.find(url_options[:_recall][:id])
    redirect_to root_url unless user_to_be_edited.id == current_user.id
  end
end

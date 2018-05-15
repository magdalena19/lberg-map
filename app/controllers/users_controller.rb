class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  before_action :require_to_be_same_user_or_admin, only: [:edit, :update]
  before_action :can_create?, only: [:create]

  def index
    @users = User.all
  end

  def sign_up
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @activation_token.invalidate if @activation_token
      WelcomeUserWorker.perform_async(@user.id)
      @user.update_attributes(maps: session[:maps]) unless @current_user&.admin?
      flash[:success] = t('.changes_saved')
      redirect
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

  def redirect
    if @current_user.admin?
      redirect_to admin_index_users_path
    else
      redirect_to maps_path
    end
  end

  def can_create?
    @activation_token = ActivationToken.find_by(token: params[:activation_token])
    unless @current_user.admin? || @activation_token.present?
      flash[:danger] = t('.invalid_token')
      render :sign_up, status: 403
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :activation_token)
  end

  def require_to_be_same_user_or_admin
    user_to_be_edited = User.find(url_options[:_recall][:id])
    redirect_to root_url unless user_to_be_edited.id == current_user.id || @current_user.admin?
  end
end

class Admin::UsersController < AdminController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :try_deleting_own_user?, only: [:destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = t('.created')
      redirect_to :admin_users
    else
      flash.now[:danger] = @user.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t('.updated')
      redirect_to :admin_users
    else
      flash.now[:danger] = @user.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash.now[:success] = t('.deleted')
      redirect_to :admin_users
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def try_deleting_own_user?
    if @user == @current_user
      redirect_to admin_users_url
      flash[:danger] = t('.cannot_delete_current_user')
    end
  end
end

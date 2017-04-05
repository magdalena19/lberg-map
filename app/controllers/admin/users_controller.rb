class Admin::UsersController < AdminController
  before_action :try_deleting_own_user?, only: [:destroy]

  def index
    @users = User.all
  end

  def destroy
    if @user.destroy
      flash.now[:success] = t('.deleted')
      redirect_to admin_index_users_path
    end
  end

  private

  def try_deleting_own_user?
    @user = User.find(params[:id])
    if @user == @current_user
      redirect_to admin_index_users_path
      flash[:danger] = t('.cannot_delete_current_user')
    end
  end
end

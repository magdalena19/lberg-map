class AnnouncementsController < ApplicationController
  before_action :require_authentication, only: [:new, :create, :edit, :update, :destroy]
  before_action :require_to_be_same_user_or_admin, only: [:edit, :update, :destroy]

  def index
    @announcements = Announcement.all
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user = User.find(session[:user_id])

    create_announcement
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update_attributes(announcement_params)
      flash[:success] = 'Changes saved!'
      redirect_to :root
    else
      flash[:success] = 'Could not save changes, please check your input for errors!'
      render :edit
    end
  end

  def destroy
    if Announcement.find(params[:id]).destroy
      flash[:success] = 'Announcement deleted!'
      redirect_to :root
    end
  end

  private

  def create_announcement
    if @announcement.save
      flash[:success] = 'Announcement published!'
      redirect_to :root
    else
      flash.now[:danger] = 'Could not create announcement!'
      redirect_to :edit
    end
  end

  def announcement_params
    params.require(:announcement).permit(:header, :content)
  end

  def require_to_be_same_user_or_admin
    announcement_to_be_edited = Announcement.find(url_options[:_recall][:id])
    unless announcement_to_be_edited.user_id == current_user.id || is_admin?
      flash.now[:danger] = 'Cannot change announcements of other users!'
      redirect_to root_path
    end
  end

  def require_authentication
    unless signed_in?
      flash.now[:danger] = 'Access to this page has been restricted. Please login first!'
      redirect_to login_path
    end
  end
end

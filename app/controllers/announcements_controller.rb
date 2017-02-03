class AnnouncementsController < ApplicationController
  before_action :require_login
  before_action :require_to_be_same_user_or_admin, only: [:edit, :update, :destroy]

  def index
    @announcements = Announcement.paginate(page: params[:page], per_page: 10).order('created_at DESC')
  end

  def show
    @announcement = Announcement.find(params[:id])
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
      flash[:success] = t('.changes_saved')
      redirect_to announcements_url
    else
      flash.now[:danger] = @announcement.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    Announcement.find(params[:id]).destroy
    flash[:success] = t('.deleted')
    redirect_to :root
  end

  private

  def create_announcement
    if @announcement.save
      flash[:success] = t('created')
      redirect_to :root
    else
      flash.now[:danger] = @announcement.errors.full_messages.to_sentence
      render :new
    end
  end

  def announcement_params
    params.require(:announcement).permit(:header, :content)
  end

  # TODO factor this out into module?
  def require_to_be_same_user_or_admin
    announcement_to_be_edited = Announcement.find(url_options[:_recall][:id])
    unless announcement_to_be_edited.user_id == current_user.id || current_user.admin?
      flash[:danger] = t('.no_right_to_edit')
      redirect_to announcements_url
    end
  end
end

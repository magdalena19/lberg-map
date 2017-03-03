class PasswordResetController < ApplicationController
  before_action :set_user, only: [:reset_password, :set_new_password]
  before_action :set_user_by_email, only: [:create_password_reset]
  before_action :authenticated?, only: [:reset_password]

  def request_password_reset
  end
  
  def create_password_reset
    @user.create_digest_for(attribute: 'password_reset')
    if @user.save
      DeliveryGul.send_password_reset_link(@user).deliver_now
      flash[:success] = t('.reset_link_sent')
    else
      flash[:danger] = t('.could_not_send_reset_link')
    end
    redirect_to root_url
  end

  def reset_password
    render 'password_reset_form', locals: { password_reset_token: params[:token], user_id: @user.id }
  end

  def set_new_password
    if passwords_match?
      new_password = params[:new_password][:password]
      @user.update_attributes(password: new_password,
                               password_confirmation: new_password,
                               password_reset_digest: nil) 
      flash[:success] = t('.new_password_set')
      redirect_to root_url
    else
      flash[:danger] = t('.passwords_do_not_match')
      reset_password
    end
  end

  private

  def set_user_by_email
    unless @user = User.find_by(email: params[:password_reset][:email])
      flash[:danger] = t('.no_account_found')
      render :request_password_reset
    end
  end

  def set_user
    @user = User.find_by(id: params[:id]) 
  end

  def authenticated?
    unless @user && token_valid? 
      flash[:danger] = t('.link_invalid')
      redirect_to root_url
    end
  end

  def token_valid?
    @user.authenticated?(attribute: :password_reset, token: params[:token]) && @user.password_reset_token_alive?
  end

  def passwords_match?
    params[:new_password][:password] == params[:new_password][:password_confirmation]
  end
end

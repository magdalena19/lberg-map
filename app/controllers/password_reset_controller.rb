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
      # TODO translate
      flash[:success] = "Ein Link zum Zurücksetzen deines Passworts wurde dir zugeschickt. Dieser ist 24h gültig!"
    else
      # TODO translate
      flash[:danger] = "Etwas ist schiefgegangen, wir können dein Passwort leider nicht zurücksetzen..."
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
      # TODO translate
      flash[:success] = "Das neue Passwort wurde erfolgreich gesetzt!"
      redirect_to root_url
    else
      # TODO translate
      flash[:danger] = "Die eingegebenen Passwörter stimmen nicht überein!"
      render :set_new_password
    end
  end

  private

  def set_user_by_email
    unless @user = User.find_by(email: params[:password_reset][:email])
      # TODO translate
      flash[:danger] = "Zu dieser Email-Adresse wurde kein passender Account gefunden!"
      redirect_to root_url
    end
  end

  def set_user
    @user = User.find_by(id: params[:id]) 
  end

  def authenticated?
    unless @user && token_valid? 
      # TODO translate
      flash[:danger] = "Link zum Passwort zurücksetzen ist ungültig!"
      redirect_to root_url
    end
  end

  def token_valid?
    @user.authenticated?(attribute: :password_reset, token: params[:token]) && @user.password_reset_token_alive?
  end

  def passwords_match?
    params[:password] == params[:password_confirmation]
  end
end

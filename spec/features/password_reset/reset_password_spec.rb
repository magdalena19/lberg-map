feature 'Reset password', js: true do
  before do
    create :settings
    @user = create :user
    @user.create_digest_for(attribute: 'password_reset')
    @user.save

    visit reset_password_path id: @user.id, token: @user.password_reset_token
  end

  scenario 'Request password reset' do
    alert_if_no_account_matches
    requests_password_reset_link
  end

  scenario 'Reset password' do
    alert_if_inputs_do_not_match
    reset_password_if_inputs_match
  end

  private

  def alert_if_no_account_matches
    visit request_password_reset_path
    fill_in('password_reset_email', with: 'unknown@test.com')
    click_on('Send password reset link')

    expect(page).to have_css('.alert-danger', text: 'Could not find an account with this email address!')
  end

  def requests_password_reset_link
    user = create :user, email: 'user@test.com'
    visit request_password_reset_path
    fill_in('password_reset_email', with: user.email)
    click_on('Send password reset link')

    expect(page).to have_css('.alert-success', text: 'A password reset link has been sent to your account email address. It is valid only for 24 hours from now on!')
    expect(user.reload.password_reset_digest).to be_a(String)
  end

  def reset_password_if_inputs_match
    fill_in('new_password_password', with: 'new_secret')
    fill_in('new_password_password_confirmation', with: 'new_secret')
    click_on('Reset password')

    new_password_digest = @user.reload.password_digest
    expect(@user.authenticated?(attribute: 'password', token: 'new_secret')).to be true
    expect(page).to have_css('.alert-success', text: 'The new password has been set successfully!')
  end

  def alert_if_inputs_do_not_match
    fill_in('new_password_password', with: 'new_secret')
    fill_in('new_password_password_confirmation', with: 'i_do_not_match')
    click_on('Reset password')

    expect(page).to have_css('.alert-danger')
    expect(page).to have_content('Passwords do not match')
  end
end

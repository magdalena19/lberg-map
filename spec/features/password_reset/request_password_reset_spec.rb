feature 'Request password reset' do
  before do
    create :settings, :public
  end

  scenario 'Has all UI elements', js: true do
    visit request_password_reset_path
    expect(page).to have_css("input[placeholder='Your account email address']")
    expect(page).to have_css("input[value='Send password reset link']")
  end

  scenario 'Requests password reset link on button click', js: true do
    user = create :user, email: 'user@test.com'

    visit request_password_reset_path
    fill_in('password_reset_email', with: user.email)
    click_on('Send password reset link')
    expect(page).to have_css('.alert-success', text: 'A password reset link has been sent to your account email address. It is valid only for 24 hours from now on!')
    expect(user.reload.password_reset_digest).to be_a(String)
  end

  scenario 'Does alert if no matching account found', js: true do
    visit request_password_reset_path
    fill_in('password_reset_email', with: 'unknown@test.com')
    click_on('Send password reset link')
    expect(page).to have_css('.alert-danger', text: 'Could not find an account with this email address!')
  end
end

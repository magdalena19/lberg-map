feature 'Reset password' do
  before do
    @user = create :user
    @user.create_digest_for(attribute: 'password_reset')
    @user.save

    visit reset_password_path id: @user.id, token: @user.password_reset_token
  end

  scenario 'Has all UI elements', js: true do
    expect(page).to have_css("input[placeholder='New password']")
    expect(page).to have_css("input[placeholder='Repeat new password']")
    expect(page).to have_css("input[value='Reset password']")
  end

  scenario 'Resets password if inputs match', js: true do
    fill_in('new_password_password', with: 'new_secret')
    fill_in('new_password_password_confirmation', with: 'new_secret')
    click_on('Reset password')

    new_password_digest = @user.reload.password_digest
    expect(@user.authenticated?(attribute: 'password', token: 'new_secret')).to be true
    expect(page).to have_css('.alert-success', text: 'The new password has been set successfully!')
  end

  scenario 'Does alert if inputs do not match', js: true do
    fill_in('new_password_password', with: 'new_secret')
    fill_in('new_password_password_confirmation', with: 'i_do_not_match')
    click_on('Reset password')

    expect(page).to have_css('.alert-danger', text: 'Passwords do not match!')
  end

  scenario 'Does not redirect if inputs do not match', js: true do
    fill_in('new_password_password', with: 'new_secret')
    fill_in('new_password_password_confirmation', with: 'i_do_not_match')
    click_on('Reset password')

    expect(page).to have_css("input[placeholder='New password']")
    expect(page).to have_css("input[placeholder='Repeat new password']")
    expect(page).to have_css("input[value='Reset password']")
  end
end

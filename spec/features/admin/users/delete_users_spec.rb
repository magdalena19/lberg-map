feature 'Delete user' do
  before do
    @users = create_list(:user, 3)
    login_as_admin
    visit admin_users_path
  end

  scenario 'can find link to delete user', :js do
    expect(page).to have_content('Delete')
  end

  scenario 'can delete user', :js do
    expect {
      within(:css, "#user_#{@users.last.id}") do
        click_on('Delete')
      end
    }.to change { User.count }.by(-1)
  end

  scenario 'cannot delete own, currently logged in user', :js do
    expect {
      within(:css, "#user_#{User.last.id}") do
        click_on('Delete')
      end
    }.to change { User.count }.by(0)
    expect(page).to have_css('.alert-danger', text: /cannot delete/)
  end
end

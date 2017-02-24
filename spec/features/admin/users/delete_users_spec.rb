feature 'Delete user' do
  before do
    create :settings
  end

  scenario 'can find link to delete user', :js do
    login_as_admin
    visit admin_users_path
    expect(page).to have_content('Delete')
  end

  scenario 'can delete user', :js do
    login_as_admin
    users = create_list(:user, 3)
    visit admin_users_path
    expect {
      within(:css, "#user_#{users.last.id}") do
        click_on('Delete')
      end
    }.to change { User.count }.by(-1)
  end

  scenario 'cannot delete own, currently logged in user', :js do
    login_as_admin
    visit admin_users_path
    expect {
      within(:css, "#user_#{User.first.id}") do
        click_on('Delete')
      end
    }.to change { User.count }.by(0)
    expect(page).to have_css('.alert-danger', text: /cannot delete/)
  end
end

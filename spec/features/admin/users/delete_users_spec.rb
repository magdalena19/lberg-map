feature 'Delete user', :js do
  before do
    @users = create_list(:user, 3)
    login_as_admin
    visit admin_index_users_path
  end

  scenario 'can find link to delete user' do
    expect(page).to have_css('.glyphicon-trash')
  end

  scenario 'can delete user' do
    page.all('.glyphicon-trash').last.trigger('click')

    expect(page).to have_css('.glyphicon-trash', count: 3)
  end

  scenario 'cannot delete own, currently logged in user' do
    page.all('.glyphicon-trash').first.trigger('click')

    expect(page).to have_css('.alert-danger', text: /cannot delete/)
  end
end

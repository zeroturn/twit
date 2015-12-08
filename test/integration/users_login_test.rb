require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:joe)
  end
  
  test 'invalid login and flash only once' do
    # flash on 'render' will display again; that is a bug
    # use flash.now to solve that problem
    get login_path
    assert_template 'sessions/new'
    post login_path session: {email: '', password: '' }
    assert_template 'sessions/new'
    assert_not flash.empty?, 'flash msg should not be empty'
    get root_path
    assert flash.empty?, 'flash msg should be empty'
  end
  
  test "login with valid information followed by logout" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end

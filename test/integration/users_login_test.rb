require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:lijunhao)
  end

  test "测试包含无效信息的登录" do
    get login_path
    assert_template 'sessions/new'
    post login_path,params: {session: {email:"",password:""}}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "测试包含有效信息的登录" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: {session: {email: @user.email,
                                        password: 'password'}}
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path,  count: 0
    assert_select "a[href=?]", logout_path, count: 1
    assert_select "a[href=?]", user_path(@user)
  end

  test "测试注册后直接登录" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    # assert_template 'users/show'
    # assert is_logged_in?
  end

  test "测试登录并且登出" do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
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

    # 模拟用户在另一个窗口中点击退出链接
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "测试登录记住功能" do
    log_in_as(@user, remember_me: '1')
    assert_equal cookies['remember_token'], assigns[:user].remember_token
  end

  test "测试登录不记住功能" do
    # 登录,设定 cookie
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # 再次登录,确认 cookie 被删除了
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end

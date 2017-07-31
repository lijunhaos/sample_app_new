require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:lijunhao)
    @other_user = users(:michael)
  end

  test "应该获取注册页面" do
    get signup_path
    assert_response :success
  end

  test "人员没有登陆时，访问编辑页面，应重定向到登录页" do
    get edit_user_path @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "人员没有登陆时，编辑用户信息，应重定向到登录页" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "一个人员登陆时，访问另一个人员的编辑页面，应重定向到根页面" do
    log_in_as(@other_user)
    get edit_user_path @user
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "一个人员登陆时，编辑另一个人员用户信息，应重定向到根页面" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "未登录的用户访问index页面，重定向到登录页" do
    get users_url
    assert_redirected_to login_url
  end
end

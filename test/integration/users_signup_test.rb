require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "无效的注册信息" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select "div[id='error_explanation']"
    assert_select "div[class= 'field_with_errors']"
  end

  test "账户激活的有效注册信息" do
    get signup_path
    assert_difference 'User.count',1 do
      post users_path,params: { user: { name: "doudou",
                                         email: "abc@qq.com",
                                         password: "111111",
                                         password_confirmation: "111111" } }
    end
    assert_equal 1,ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # 尝试在激活之前登录
    log_in_as(user)
    assert_not is_logged_in?
    # 激活令牌无效
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # 令牌有效,电子邮件地址不对
    get edit_account_activation_path(user.activation_token,email: 'wrong')
    assert_not is_logged_in?
    # 激活令牌有效
    get edit_account_activation_path(user.activation_token,email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end

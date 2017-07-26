require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

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

  test "有效的注册信息" do
    get signup_path
    assert_difference 'User.count',1 do
      post signup_path,params: { user: { name: "doudou",
                                         email: "abc@qq.com",
                                         password: "111111",
                                         password_confirmation: "111111" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
end

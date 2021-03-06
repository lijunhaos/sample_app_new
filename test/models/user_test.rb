require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name:"lijunhao",email:"lijunhao@6ceng.com",
                     password: "111111", password_confirmation: "111111")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
    # puts @user.errors.messages
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
    # puts @user.errors.messages
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    upcase_email = "Foo@ExAMPle.CoM"
    @user.email = upcase_email
    @user.save
    assert_equal upcase_email.downcase, @user.reload.email
  end

  test "password should be present (notBlank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "测试令牌为空，authenticated?应该返回false" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "关联的微薄应该被删除" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    lijunhao = users(:lijunhao)
    archer = users(:archer)
    assert_not lijunhao.following?(archer)
    lijunhao.follow(archer)
    assert lijunhao.following?(archer)
    assert archer.followers.include?(lijunhao)
    lijunhao.unfollow(archer)
    assert_not lijunhao.following?(archer)
  end

  test "feed should have the right posts" do
    lijunhao = users(:lijunhao)
    archer = users(:archer)
    lana = users(:lana)

    # 关注的用户发布的微博
    lana.microposts.each do |post_following|
      assert lijunhao.feed.include?(post_following)
    end

    # 自己的微博
    lijunhao.microposts.each do |post_self|
      assert lijunhao.feed.include?(post_self)
    end

    # 未关注用户的微博
    archer.microposts.each do |post_unfolowed|
      assert_not lijunhao.feed.include?(post_unfolowed)
    end
  end
end

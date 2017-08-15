require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:lijunhao)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # 无效提交
    post microposts_path, micropost: { content: "" }
    assert_select 'div#error_explanation'
    # 有效提交
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, picture: picture } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 删除一篇微博
    assert_select 'a', text: '删除'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 访问另一个用户的资料页面(没有删除链接)
    get user_path(users(:archer))
    assert_select 'a', text: '删除', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match @user.microposts.count.to_s, response.body
    # 这个用户没有发布微博
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1", response.body
  end
end
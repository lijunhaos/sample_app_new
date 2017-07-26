require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title, '星星论坛'
    assert_equal full_title("Help"), 'Help | 星星论坛'
  end
end
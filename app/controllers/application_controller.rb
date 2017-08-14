class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def hello
    render html: "hello, world!"
  end

  private
    # 前置过滤器
    # 确保用户已登录
    def logged_in_user
      unless logged_in
        store_location
        flash[:danger] = "请登录!"
        redirect_to login_url
      end
    end
end

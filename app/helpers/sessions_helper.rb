module SessionsHelper

  # 登入指定的用户
  # session 方法与生成的 Sessions 控制器没有关系。
  # 这么做会在用户的浏览器中创建一个临时 cookie,内容是加密后的用户 ID。
  def log_in(user)
    session[:user_id] = user.id
  end

  # 返回当前登录的用户(如果有的话)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # 判断是否在登录状态
  def logged_in
    !current_user.nil?
  end

  # 退出当前用户
  def logout
    session.delete(:user_id)
    @current_user = nil
  end
end

class SessionsController < ApplicationController
  #登录,获取页面 get: /login
  def new
  end

  #登录,提交数据 post: /login
  def create
    @user = User.find_by(email:params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      # 登入用户,然后重定向到用户的资料页面
      log_in @user
      params[:session][:remember_me] == '1'? remember(@user) : forget(@user)
      redirect_back_or @user
    else
      # 创建一个错误消息
      flash.now[:danger] = 'email或密码错误'
      render 'new'
    end
  end

  #登出
  def destroy
    log_out if logged_in
    redirect_to root_path
  end
end

class PasswordResetsController < ApplicationController
  before_action :get_user,          only: [:edit, :update]
  before_action :valid_user,        only: [:edit, :update]
  before_action :check_expiration,  only: [:edit, :update]  # 第一种情况

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "密码重置信息已经发送到Email"
      redirect_to root_url
    else
      flash.now[:danger] = "不存在该邮箱"
      render 'new'
    end
  end

  def edit
  end

  #1. 密码重设请求已过期
  #2. 填写的新密码无效,更新失败
  #3. 没有填写密码和密码确认,更新失败(看起来像是成功了)
  #4. 成功更新密码
  def update
    if params[:user][:password].empty?
      @user.errors.add(:password,"密码不能为空")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "密码重置成功"
      redirect_to @user
    else
      render 'edit'
    end
  end


  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 确保是有效用户
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset,params[:id]))
        redirect_to root_url
      end
    end

    # 检查重设令牌是否过期
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "密码重置超时!"
        redirect_to new_password_reset_url
      end
    end
end

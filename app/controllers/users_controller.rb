class UsersController < ApplicationController
  before_action :logged_in_user,  only: [:index, :edit, :update, :destroy]
  before_action :correct_user,    only: [:edit, :update]
  # before_action :admin_user,      only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "欢迎来到星星论坛!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit

  end

  def update
    if @user.update_attributes(user_params)
      # 处理更新成功的情况
      flash[:success] = "个人信息修改成功!"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private
    #健壮参数
    def user_params
      params.require(:user).permit(:name,:email,:password,:password_confirmation)
    end

    # 前置过滤器
    # 确保用户已登录
    def logged_in_user
      unless logged_in
        store_location
        flash[:danger] = "请登录!"
        redirect_to login_url
      end
    end

    # 确保是正确的用户
    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user?(@user)
    end

    # 确保是管理员
    # def admin_user
    #   redirect_to(root_url) unless current_user.admin?
    # end
end

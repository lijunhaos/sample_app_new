class UsersController < ApplicationController

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

  private
    #健壮参数
    def user_params
      params.require(:user).permit(:name,:email,:password,:password_confirmation)
    end
end

class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      SendEmailJob.new.perform(@user)
      redirect_to users_path, notice: "Your proposal has been submitted\
       and is under board review....proposal denied."
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :content)
  end
end

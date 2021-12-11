class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    # 実装は未完了
    @user = User.new(params[:id])
    if @user.save
    else
      render 'new'
    end
  end
  
end

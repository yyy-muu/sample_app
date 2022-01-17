class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  
  # パスワード再設定の有効期限が切れていないか
  before_action :check_expiration, only: [:edit, :update]    # （1）への対応

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    
    # 新しいパスワードが空文字列になっていないか
    if params[:user][:password].empty?                  # （3）への対応
      @user.errors.add(:password, :blank)
      render 'edit'
      
    # 新しいパスワードが正しければ、更新する
    elsif @user.update(user_params)                     # （4）への対応
      log_in @user
      
      # パスワード再設定が成功したらダイジェストをnilにする
      @user.update_attribute(:reset_digest, nil)
      
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      
      # 無効なパスワードであれば失敗させる（失敗した理由も表示する）
      render 'edit'                                     # （2）への対応
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # beforeフィルタ

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 有効なユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
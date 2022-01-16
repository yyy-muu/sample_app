class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "メールアドレス/パスワードが間違えています"
      render 'new'
    end
  end
  
  # セッションを破棄する
  def destroy
    # logged_in?がtrueの場合に限ってlog_outを呼び出す
    log_out if logged_in?
    redirect_to root_url
  end
  
end

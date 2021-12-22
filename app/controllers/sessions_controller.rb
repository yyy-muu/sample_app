class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    
    # if user && user.authenticate(params[:session][:password])
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      # user_url(user)ルーティングに変換している
      
      # チェックボックスがオンのときにユーザーを記憶し、
      # オフのときには記憶しない
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      
      # ログイン後、ユーザ情報ページにリダイレクトする
      redirect_to @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
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

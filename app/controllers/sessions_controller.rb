class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # ログイン後、ユーザ情報ページにリダイレクトする
    # if user && user.authenticate(params[:session][:password])
    if user&.authenticate(params[:session][:password])
      log_in user
      # user_url(user)ルーティングに変換している
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
  
  # セッションを破棄する
  def destroy
    log_out
    redirect_to root_url
  end
  
end

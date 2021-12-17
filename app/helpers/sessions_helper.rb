module SessionsHelper
  
  # ユーザ情報を引数として渡し、ログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
  
  # ユーザがログイン状態でtrueを返し、それ以外の状態ならfalseを返す
  # ログイン状態 = sessionにユーザーidが存在している
  def logged_in?
    !current_user.nil?
  end
  
end

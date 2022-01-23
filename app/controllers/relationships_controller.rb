# ビューで変数を使うため、userを@userにする

# リレーションシップのアクセス制御
class RelationshipsController < ApplicationController
  # 未ログインユーザはログインさせる
  before_action :logged_in_user

  def create
    
    # followed_idに対応するユーザーを見つけてくる
    @user = User.find(params[:followed_id])
    
    # 見つけてきたユーザーに対して適切にフォローメソッドを使う
    current_user.follow(@user)
    
    # Ajaxリクエストに対応
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    
    # Ajaxリクエストに対応
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
class UsersController < ApplicationController
  # 何らかの処理が実行される直前に特定のメソッドを実行する
  # コントローラ内のすべてのアクションに適用させないため、only:オプションで指定する
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  
  
  
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  
  # 全ユーザーが格納された変数を作成し
  # 順々に表示するindexビューを実装
  def index
    # @users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def show
    # @user = User.find(params[:id])
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      
      # ユーザー登録にアカウント有効化を追加
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # 更新に成功した場合を扱う。
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  # 該当するユーザーを見つけActive Recordのdestroyメソッドを使って削除
  # 最後にユーザーindexに移動
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  
  def following
    # タイトルを設定
    @title = "Following"
    
    # # ユーザーを検索しデータを取り出す
    @user  = User.find(params[:id])
    
    # ページネーションを行なう、ページを出力
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    
    # beforeアクション
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end
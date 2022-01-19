class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  # createアクションへの送信が失敗(投稿失敗)した場合に備えて、
  # 必要なフィード変数をこのブランチで渡し
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  # 投稿の削除
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    
    # 一つ前のURLを返す
    # DELETEリクエストが発行されたページに戻す
    # 元に戻すURLが見つからなかった場合、root_urlに返す
    # redirect_to request.referrer || root_url、下記でも可（Rails 5〜）
    redirect_back(fallback_location: root_url)
  end

  private

    # Strong Parameters
    # content属性だけがWeb経由で変更可能
    def micropost_params
      params.require(:micropost).permit(:content)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
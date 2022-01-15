require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest


  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    
    # paginationクラスを持ったdivタグをチェック
    # will_paginateのリンクが２つとも存在していること
    assert_select 'div.pagination', count: 2
    
    # 最初のページにユーザーがいることを確認
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
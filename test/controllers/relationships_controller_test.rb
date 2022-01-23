# フォローとフォロー解除はそれぞれリレーションシップの作成と削除に対応しているため、まずはRelationshipsコントローラが必要

# もしログインしていないユーザーが（curlなどのコマンドラインツールなどを使って）これらのアクションに直接アクセスするようなことがあれば、current_userはnilになり、どちらのメソッドでも2行目で例外が発生します。
# エラーにはなりますが、アプリケーションやデータに影響は生じません。
# このままでも支障はありませんが、やはりこのような例外には頼らない方がよいので、下記のログインチェックをおこなう

# コントローラのアクションにアクセスするとき、ログイン済みのユーザーであるかどうかをチェックします。
# もしログインしていなければログインページにリダイレクト
require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # フォローする＝Relationshipを作成する
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  # フォロー解除する＝Relationshipを削除する
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end

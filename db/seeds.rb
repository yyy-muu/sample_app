# データベース上にサンプルユーザーを生成するRailsタスク(スクリプト)

# メインのサンプルユーザーを1人作成する
# create! ユーザーが無効な場合にfalseを返すのではなく例外を発生させる
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
            # 最初のユーザーだけをデフォルトで管理者にする
             admin: true,
             
            # サンプルユーザーを最初から有効にしておく
             activated: true,
             
            # Railsの組み込みヘルパー
            # サーバーのタイムゾーンに応じたタイムスタンプを返し
             activated_at: Time.zone.now)

# 追加のユーザーを99回まとめて生成する
99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

# ユーザーの一部を対象にマイクロポストを生成する

# 作成されたユーザーの最初の6人を明示的に呼び出す
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end
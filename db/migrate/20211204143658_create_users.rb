class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    # ユーザーを保存するためのテーブルをデータベースに作成
    create_table :users do |t|
      # tオブジェクトを使って、nameとemailカラムをデータベースに作成
      t.string :name
      t.string :email

      # created_atとupdated_atという２つの「マジックカラム（Magic Columns）」を作成
      t.timestamps
    end
  end
end

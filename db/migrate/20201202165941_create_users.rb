class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :password,              null: false, default: ""
      t.string :token,              null: false, default: ""
      t.datetime  :token_expiration
      t.timestamps
    end
  end
end

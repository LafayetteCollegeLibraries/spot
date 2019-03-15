class ModifyUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.remove_index :reset_password_token

      t.remove :reset_password_token,
               :reset_password_sent_at,
               :current_sign_in_ip,
               :last_sign_in_ip

      t.string :username
      t.index :username, unique: true
    end
  end
end

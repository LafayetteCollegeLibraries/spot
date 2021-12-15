class UpdateUserFields < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :facebook_handle
    remove_column :users, :twitter_handle
    remove_column :users, :googleplus_handle

    add_column :users, :lnumber, :string
  end

  def down
    remove_column :users, :lnumber

    add_column :users, :facebook_handle, :string
    add_column :users, :twitter_handle, :string
    add_column :users, :googleplus_handle, :string
  end
end

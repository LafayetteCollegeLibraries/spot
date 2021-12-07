class UpdateUserFields < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :facebook_handle
    remove_column :users, :twitter_handle
    remove_column :users, :googleplus_handle

    # convert `User#affiliation` to an enum field (currently unused as :string)
    change_column :users, :affiliation, :integer, default: 0, using: 'affiliation::integer'
    add_column :users, :lnumber, :string
  end

  def down
    remove_column :users, :lnumber
    change_column :users, :affiliation, :string

    add_column :users, :facebook_handle, :string
    add_column :users, :twitter_handle, :string
    add_column :users, :googleplus_handle, :string
  end
end

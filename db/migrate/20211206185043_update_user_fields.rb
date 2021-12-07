class UpdateUserFields < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      # drop socials
      t.remove :facebook_handle, :string
      t.remove :twitter_handle, :string
      t.remove :googleplus_handle, :string

      # add lnumber (string) and affiliation (enum)
      t.string :lnumber
      t.integer :affiliation
    end
  end

  def down
    change_table :users do |t|
      # drop our additions
      t.remove :lnumber, :string
      t.remove :affiliation, :integer

      # add our removals
      t.string :facebook_handle
      t.string :twitter_handle
      t.string :googleplus_handle
    end
  end
end

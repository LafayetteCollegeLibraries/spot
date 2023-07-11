# Undoes 20200128221650_revert_single_use_links_keys
class RevertSingleUseLinksColumnNames < ActiveRecord::Migration[5.2]
  def change
    rename_column :single_use_links, :downloadKey, :download_key
    rename_column :single_use_links, :itemId, :item_id
  end
end

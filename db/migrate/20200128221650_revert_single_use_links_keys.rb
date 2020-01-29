class RevertSingleUseLinksKeys < ActiveRecord::Migration[5.1]
  def change
    rename_column :single_use_links, :download_key, :downloadKey
    rename_column :single_use_links, :item_id, :itemId
  end
end

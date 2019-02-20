class CreateFeaturedCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :featured_collections do |t|
      t.integer :order, default: 4
      t.string :collection_id

      t.timestamps null: false
    end

    add_index :featured_collections, :collection_id
    add_index :featured_collections, :order
  end
end

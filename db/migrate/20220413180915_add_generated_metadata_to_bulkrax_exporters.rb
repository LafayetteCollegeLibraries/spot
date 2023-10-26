class AddGeneratedMetadataToBulkraxExporters < ActiveRecord::Migration[5.1]
  def change
    add_column :bulkrax_exporters, :generated_metadata, :boolean, default: false unless column_exists?(:bulkrax_exporters, :generated_metadata)
    add_column :bulkrax_exporters, :include_collections, :boolean, default: false unless column_exists?(:bulkrax_exporters, :include_collections)
    add_column :bulkrax_exporters, :include_filesets, :boolean, default: false unless column_exists?(:bulkrax_exporters, :include_filesets)
  end
end
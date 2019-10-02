class AddFixityCheckBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :fixity_check_batches do |t|
      t.json :summary
      t.boolean :completed
      t.timestamps
    end

    create_join_table :checksum_audit_logs, :fixity_check_batches do |t|
      t.index :checksum_audit_log_id, name: 'index_audits_checksum_audit_log_id'
      t.index :fixity_check_batch_id, name: 'index_audits_fixity_check_batch_id'
    end
  end
end

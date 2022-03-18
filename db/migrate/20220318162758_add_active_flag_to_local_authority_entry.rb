class AddActiveFlagToLocalAuthorityEntry < ActiveRecord::Migration[5.2]
  def up
    add_column :qa_local_authority_entries, :active, :boolean, default: true
  end

  def down
    remove_column :qa_local_authority_entries, :active
  end
end

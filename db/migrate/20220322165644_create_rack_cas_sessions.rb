class CreateRackCasSessions < ActiveRecord::Migration[5.2]
  def self.up
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.string :cas_ticket
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :cas_ticket
    add_index :sessions, :updated_at
  end

  def self.down
    drop_table :sessions
  end
end

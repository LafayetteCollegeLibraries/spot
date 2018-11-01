class CreateRdfLabel < ActiveRecord::Migration[5.1]
  def change
    create_table :rdf_labels do |t|
      t.string :uri, null: false
      t.string :value, null: false
      t.timestamps
    end
  end
end

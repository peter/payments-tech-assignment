class CreateMunicipalities < ActiveRecord::Migration[7.0]
  def change
    create_table :municipalities do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :municipalities, :name, unique: true

    add_column :packages, :municipality_id, :integer, foreign_key: true
    remove_index :packages, :name
    add_index :packages, [:name, :municipality_id], unique: true
  end
end

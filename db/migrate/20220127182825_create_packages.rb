class CreatePackages < ActiveRecord::Migration[7.0]
  def change
    create_table :packages do |t|
      t.integer :price_cents, null: false, default: 0
      t.string :name, null: false

      t.timestamps
    end
    add_index :packages, :name, unique: true
  end
end

class AddPriceValidFromAndTo < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :price_valid_from, :datetime
    add_column :prices, :price_valid_from, :datetime
    add_column :prices, :price_valid_to, :datetime
    # TODO: set price_valid_from/price_valid_to for existing rows here?
  end
end

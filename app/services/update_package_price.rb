# frozen_string_literal: true

class UpdatePackagePrice
  def self.call(package, new_price_cents, **options)
    Package.transaction do
      # Add a pricing history record
      Price.create!(package: package, price_cents: package.price_cents)

      # Update the current price
      package.update!(price_cents: new_price_cents)
    end
  end
end

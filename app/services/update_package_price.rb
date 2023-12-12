# frozen_string_literal: true

class UpdatePackagePrice
  def self.call(package, new_price_cents, **options)
    Package.transaction do
      municipality = options[:municipality] && Municipality.where(name: options[:municipality]).first_or_create!
      existing_package = Package.find_by(name: package.name, municipality: municipality)
      if existing_package
        # A package matching name and municipality exists - update it
        update_package_price!(existing_package, municipality, new_price_cents)
      else
        # No package matching name and municipality exists - create it        
        create_package_price!(package.name, municipality, new_price_cents)
      end
    end
  end

  def self.update_package_price!(existing_package, municipality, new_price_cents)
    if existing_package.price_cents == new_price_cents
      raise ArgumentError, "Cannot update price of package to #{new_price_cents} as it already has that price: #{existing_package.as_json}"
    end
    # Update price_valid_to for existing price record
    current_time = Time.current
    current_price = existing_package.prices.last
    if current_price
      current_price.update!(price_valid_to: current_time)
    end
    # Add a price history record for the new price
    Price.create!(
      package: existing_package,
      price_cents: new_price_cents,
      price_valid_from: current_time
    )
    # Update the current price of package
    existing_package.update!(
      price_cents: new_price_cents,
      price_valid_from: current_time
    )
  end

  def self.create_package_price!(package_name, municipality, new_price_cents)
    Package.create!(
      name: package_name,
      municipality: municipality,
      price_cents: new_price_cents,
      price_valid_from: Time.current
    )
  end
end

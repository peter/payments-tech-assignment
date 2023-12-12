# frozen_string_literal: true

class PriceHistory
  def self.call(**options)
    package_name, year, municipality = parse_call_options!(options)
    packages = Package.includes(:prices).where(name: package_name)
    if year
      start_date_string = "#{year}-01-01"
      start_date = Date.parse(start_date_string).beginning_of_year
      end_date = start_date.next_year.beginning_of_year
      packages = packages.where(prices: {price_valid_from: start_date...end_date})
    end
    if municipality
      packages = packages.where(municipality: municipality)
    end
    packages.reduce({}) do |acc, package|
      group_name = package.municipality.try(:name)
      prices = package.prices.map(&:price_cents)
      if prices.present?
        acc[group_name] = prices
      end
      acc
    end
  end

  def self.is_valid_int_string(value_string)
    value_string && value_string.instance_of?(String) && value_string.to_i.to_s == value_string
  end
  
  def self.is_valid_iso_year(year_string)
    return is_valid_int_string(year_string) && year_string.length == 4 && year_string.to_i > 0
  end
  
  def self.parse_call_options!(options)
    if !options[:package].try(:name)
      raise ArgumentError, 'The price history package argument must be provided'
    end
    if options[:year] && !is_valid_iso_year(options[:year])
      raise ArgumentError, "The price history year argument must be a valid 4 digit ISO year but was '#{options[:year]}'"
    end
    if options[:municipality]
      municipality = Municipality.find_by(name: options[:municipality])
      if !municipality
        raise ArgumentError, "Cound not find municipality with name='#{options[:municipality]}'"
      end
    end
    return [options[:package].name, options[:year], municipality]
  end  
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe PriceHistory do
  # These tests cover feature request 2. Feel free to add more tests or change
  # the existing ones.

  xit "returns the pricing history for the provided year and package" do
    basic = Package.create!(name: "basic")

    travel_to Time.zone.local(2019) do
      # These should NOT be included
      UpdatePackagePrice.call(basic, 20_00, municipality: "Stockholm")
      UpdatePackagePrice.call(basic, 30_00, municipality: "Göteborg")
    end

    travel_to Time.zone.local(2020) do
      UpdatePackagePrice.call(basic, 30_00, municipality: "Stockholm")
      UpdatePackagePrice.call(basic, 40_00, municipality: "Stockholm")
      UpdatePackagePrice.call(basic, 100_00, municipality: "Göteborg")
    end

    history = PriceHistory.call(package: basic, year: "2020")
    expect(history).to eq(
      "Göteborg" => [100_00],
      "Stockholm" => [30_00, 40_00],
    )
  end

  xit "supports filtering on municipality" do
    basic = Package.create!(name: "basic")

    travel_to Time.zone.local(2020) do
      UpdatePackagePrice.call(basic, 30_00, municipality: "Stockholm")
      UpdatePackagePrice.call(basic, 40_00, municipality: "Stockholm")
      UpdatePackagePrice.call(basic, 100_00, municipality: "Göteborg")
    end

    # Whoops no assertions, please add some
  end
end

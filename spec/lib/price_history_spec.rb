# frozen_string_literal: true

require "spec_helper"

RSpec.describe PriceHistory do
  # These tests cover feature request 2. Feel free to add more tests or change
  # the existing ones.

  it "throws an error if a package is not provided" do
    expect {
      PriceHistory.call()
    }.to raise_error(ArgumentError)
  end

  it "returns the pricing history for only a package" do
    basic = Package.create!(name: "basic")

    UpdatePackagePrice.call(basic, 20_00)

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

    history = PriceHistory.call(package: basic)
    expect(history).to eq(
      nil => [0, 20_00],
      "Göteborg" => [30_00, 100_00],
      "Stockholm" => [20_00, 30_00, 40_00],
    )
  end

  it "returns the pricing history for the provided year and package" do
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

  it "supports filtering on municipality" do
    basic = Package.create!(name: "basic")

    travel_to Time.zone.local(2020) do
      UpdatePackagePrice.call(basic, 30_00, municipality: "Stockholm")
      UpdatePackagePrice.call(basic, 40_00, municipality: "Stockholm")
      UpdatePackagePrice.call(basic, 100_00, municipality: "Göteborg")
    end

    history = PriceHistory.call(package: basic, year: "2020", municipality: "Stockholm")
    expect(history).to eq(
      "Stockholm" => [30_00, 40_00],
    )
  end
end

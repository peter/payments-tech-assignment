# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdatePackagePrice do
  it "updates the current price of the provided package" do
    package = Package.create!(name: "Dunderhonung")

    UpdatePackagePrice.call(package, 200_00)
    expect(package.reload.price_cents).to eq(200_00)
  end

  it "only updates the passed package price" do
    package = Package.create!(name: "Dunderhonung")
    other_package = Package.create!(name: "Farmors köttbullar", price_cents: 100_00)

    expect {
      UpdatePackagePrice.call(package, 200_00)
    }.not_to change {
      other_package.reload.price_cents
    }
  end

  it "stores the old price of the provided package in its price history" do
    package = Package.create!(name: "Dunderhonung", price_cents: 100_00)

    UpdatePackagePrice.call(package, 200_00)
    expect(package.prices).to be_one
    price = package.prices.first
    expect(price.price_cents).to eq(100_00)
  end

  # This tests covers feature request 1. Feel free to add more tests or change
  # the existing one.

  xit "supports adding a price for a specific municipality" do
    package = Package.create!(name: "Dunderhonung")

    UpdatePackagePrice.call(package, 200_00, municipality: "Göteborg")

    # You'll need to implement Package#price_for
    expect(package.price_for("Göteborg")).to eq(200_00)
  end
end

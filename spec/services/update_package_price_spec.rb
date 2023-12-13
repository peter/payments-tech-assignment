# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdatePackagePrice do
  it "updates the current price of the provided package" do
    package = Package.create!(name: "Dunderhonung")
    expect(package.reload.price_cents).to eq(0)

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

  it "stores the old and new prices of the provided package in its price history" do
    package = Package.create!(name: "Dunderhonung", price_cents: 100_00)
    expect(package.prices).to be_one

    UpdatePackagePrice.call(package, 200_00)
    expect(package.prices.count).to eq(2)
    expect(package.prices.first.price_cents).to eq(100_00)
    expect(package.prices.last.price_cents).to eq(200_00)
  end

  # This tests covers feature request 1. Feel free to add more tests or change
  # the existing one.

  it "supports creating a price for a specific municipality (creates new package)" do
    package = Package.create!(name: "Dunderhonung")
    expect(package.reload.price_cents).to eq(0)

    expect {
      UpdatePackagePrice.call(package, 200_00, municipality: "Göteborg")
    }.to change {
      Package.count
    }.by(1)

    expect(package.reload.price_cents).to eq(0) # unchanged
    expect(package.price_for("Göteborg")).to eq(200_00)
    municipality = Municipality.find_by(name: "Göteborg")
    municipality_package = Package.find_by(name: "Dunderhonung", municipality: municipality)
    expect(municipality_package.price_cents).to eq(200_00)
    prices = municipality_package.prices
    expect(prices.length).to eq(1)
    expect(prices[0].price_cents).to eq(200_00)
  end

  it "supports updating a price for a specific municipality (updates existing package)" do
    package = Package.create!(name: "Dunderhonung")
    expect(package.reload.price_cents).to eq(0)

    expect {
      UpdatePackagePrice.call(package, 200_00, municipality: "Göteborg")
    }.to change {
      Package.count
    }.by(1)

    expect {
      UpdatePackagePrice.call(package, 400_00, municipality: "Göteborg")
    }.to change {
      Package.count
    }.by(0)

    expect(package.reload.price_cents).to eq(0) # unchanged
    expect(package.price_for("Göteborg")).to eq(400_00)
    municipality = Municipality.find_by(name: "Göteborg")
    municipality_package = Package.find_by(name: "Dunderhonung", municipality: municipality)
    expect(municipality_package.price_cents).to eq(400_00)
    prices = municipality_package.prices
    expect(prices.length).to eq(2)
    expect(prices[0].price_cents).to eq(200_00)
    expect(prices[1].price_cents).to eq(400_00)
  end
end

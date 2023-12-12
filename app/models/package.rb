# frozen_string_literal: true

class Package < ApplicationRecord
  has_many :prices, -> { order(:created_at) }, dependent: :destroy
  belongs_to :municipality, optional: true

  validates :name, presence: true, uniqueness: { scope: :municipality }
  validates :price_cents, presence: true

  after_initialize :set_defaults
  after_create :create_initial_price!

  def price_for(municipality_name)
    municipality = Municipality.find_by(name: municipality_name)
    return nil if !municipality
    Package.find_by(name: name, municipality: municipality).try(:price_cents)
  end

  def set_defaults
    # When we create a new package the price is valid from the current time
    self.price_valid_from ||= Time.current
  end

  def create_initial_price!
    self.prices.create!(
      price_cents: self.price_cents,
      price_valid_from: self.price_valid_from || Time.current
    )
  end
end

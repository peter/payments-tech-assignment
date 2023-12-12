# frozen_string_literal: true

class Package < ApplicationRecord
  has_many :prices, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :price_cents, presence: true
end

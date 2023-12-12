class Municipality < ApplicationRecord
    has_many :packages
    
    validates :name, presence: true, uniqueness: true
end

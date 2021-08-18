class Package < ApplicationRecord
  validates :name, :version, presence: true
end

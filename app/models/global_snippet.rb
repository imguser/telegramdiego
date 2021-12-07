class GlobalSnippet < ApplicationRecord
  validates :name, uniqueness: true, presence: true

  def self.available
    self.all.pluck(:name, :value).to_h
  end
end

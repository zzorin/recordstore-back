class Record < ApplicationRecord
  belongs_to :user
  belongs_to :artist
  validates :title, :year, presence: true
end

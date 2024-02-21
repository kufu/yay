class Blog < ApplicationRecord
  has_many :entries, dependent: :destroy
end

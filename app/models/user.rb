class User < ApplicationRecord
  has_many :posts, dependent: :nullify
  has_many :comments, dependent: :nullify
  validates :Username, presence: true
end

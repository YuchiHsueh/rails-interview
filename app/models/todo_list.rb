class TodoList < ApplicationRecord
  belongs_to :user, optional: true
  has_many :items, dependent: :destroy

  validates :name, presence: true
end

class Item < ApplicationRecord
  belongs_to :todo_list
  validates :title, presence: true

  def completed?
    completed
  end

  def complete!
    update(completed: true)
  end
end

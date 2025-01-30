FactoryBot.define do
  factory :item do
    sequence(:title) { |n| "Item #{n}" }
    sequence(:description) { |n| "Description for item #{n}" }
    completed { false }
    association :todo_list
  end
end

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { should belong_to(:todo_list) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_inclusion_of(:completed).in_array([true, false]) }
  end

  describe 'creation' do
    let(:todo_list) { create(:todo_list) }

    it 'creates a valid item' do
      item = build(:item, todo_list: todo_list, title: 'Test Item')
      expect(item).to be_valid
    end

    it 'is invalid without a title' do
      item = build(:item, todo_list: todo_list, title: nil)
      expect(item).not_to be_valid
      expect(item.errors[:title]).to include("can't be blank")
    end

    it 'is valid without a description' do
      item = build(:item, todo_list: todo_list, title: 'Test Item', description: nil)
      expect(item).to be_valid
    end

    it 'sets completed to false by default' do
      item = create(:item, todo_list: todo_list, title: 'Test Item')
      expect(item.completed).to be false
    end

    it 'is invalid without a todo list' do
      item = build(:item, todo_list: nil, title: 'Test Item')
      expect(item).not_to be_valid
      expect(item.errors[:todo_list]).to include("must exist")
    end
  end
end

require 'rails_helper'

RSpec.describe TodoList, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
    it { should have_many(:items).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'creation' do
    it 'creates a valid todo list with a user' do
      user = create(:user)
      todo_list = build(:todo_list, user: user, name: 'My Todo List')
      expect(todo_list).to be_valid
    end

    it 'creates a valid todo list without a user' do
      todo_list = build(:todo_list, user: nil, name: 'My Todo List')
      expect(todo_list).to be_valid
    end

    it 'is invalid without a name' do
      todo_list = build(:todo_list, name: nil)
      expect(todo_list).not_to be_valid
      expect(todo_list.errors[:name]).to include("can't be blank")
    end
  end

  describe 'items association' do
    let(:todo_list) { create(:todo_list, name: 'My Todo List') }

    it 'can have many items' do
      create(:item, todo_list: todo_list, title: 'First Item')
      create(:item, todo_list: todo_list, title: 'Second Item')
      expect(todo_list.items.count).to eq(2)
    end

    it 'destroys associated items when deleted' do
      create(:item, todo_list: todo_list, title: 'Test Item')
      expect { todo_list.destroy }.to change(Item, :count).by(-1)
    end
  end
end

require 'rails_helper'

RSpec.describe Api::TodoListsController, type: :controller do
  let!(:todo_list) { create(:todo_list, name: 'Setup RoR project') }

  describe 'GET #index' do
    it 'returns paginated todo lists' do
      get :index, format: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      expect(json_response['todo_lists']).to be_present
      expect(json_response['total_pages']).to be_present
      expect(json_response['current_page']).to be_present
      expect(json_response['total_count']).to be_present
    end

    it 'respects per_page parameter' do
      5.times { create(:todo_list) }

      get :index, params: { per_page: 3 }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['todo_lists'].length).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'returns the todo list' do
      get :show, params: { id: todo_list.id }, format: :json

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['id']).to eq(todo_list.id)
      expect(JSON.parse(response.body)['name']).to eq(todo_list.name)
    end

    it 'returns not found for non-existent todo list' do
      get :show, params: { id: 999999 }, format: :json

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Todo list not found')
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        todo_list: { name: 'New Todo List' }
      }
    end

    let(:invalid_params) do
      {
        todo_list: { name: '' }
      }
    end

    context 'with valid parameters' do
      it 'creates a new todo list' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(TodoList, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['msg']).to eq('Todo list created successfully')
        expect(json_response['todo_list']['name']).to eq('New Todo List')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a todo list' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(TodoList, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: todo_list.id,
        todo_list: { name: 'Updated Name' }
      }
    end

    let(:invalid_update_params) do
      {
        id: todo_list.id,
        todo_list: { name: '' }
      }
    end

    context 'with valid parameters' do
      it 'updates the todo list' do
        patch :update, params: update_params, format: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['msg']).to eq('Todo list updated successfully')
        expect(todo_list.reload.name).to eq('Updated Name')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the todo list' do
        patch :update, params: invalid_update_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
      end
    end

    context 'when todo list does not exist' do
      it 'returns not found status' do
        patch :update, params: {
          id: 999999,
          todo_list: { name: 'Updated Name' }
        }, format: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Todo list not found')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the todo list' do
      expect {
        delete :destroy, params: { id: todo_list.id }, format: :json
      }.to change(TodoList, :count).by(-1)

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['msg']).to eq('Todo list deleted successfully')
    end

    it 'returns not found for non-existent todo list' do
      delete :destroy, params: { id: 999999 }, format: :json

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Todo list not found')
    end
  end
end

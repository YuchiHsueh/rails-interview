require 'rails_helper'

RSpec.describe Api::ItemsController, type: :controller do
  let(:todo_list) { create(:todo_list) }
  let!(:item) { create(:item, todo_list: todo_list, title: "Test Item", completed: false) }
  let(:other_todo_list) { create(:todo_list) }
  let(:other_item) { create(:item, todo_list: other_todo_list) }

  describe 'GET #index' do
    it 'returns paginated items' do
      get :index, params: { todo_list_id: todo_list.id }, format: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      expect(json_response['items']).to be_present
      expect(json_response['total_pages']).to be_present
      expect(json_response['current_page']).to be_present
      expect(json_response['total_count']).to be_present
    end

    it 'respects per_page parameter' do
      5.times { create(:item, todo_list: todo_list) }

      get :index, params: { todo_list_id: todo_list.id, per_page: 3 }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['items'].length).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'returns the item' do
      get :show, params: { todo_list_id: todo_list.id, id: item.id }, format: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['item']['id']).to eq(item.id)
    end

    it 'returns not found for non-existent item' do
      get :show, params: { todo_list_id: todo_list.id, id: 999999 }, format: :json

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Item not found')
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        todo_list_id: todo_list.id,
        item: { title: "New Item", description: "Description" }
      }
    end

    let(:invalid_params) do
      {
        todo_list_id: todo_list.id,
        item: { title: "" }
      }
    end

    context 'with valid parameters' do
      it 'creates a new item' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(Item, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['msg']).to eq('Item created successfully')
        expect(json_response['item']['title']).to eq('New Item')
      end
    end

    context 'with invalid parameters' do
      it 'does not create an item' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(Item, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank")
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        todo_list_id: todo_list.id,
        id: item.id,
        item: { title: "Updated Title" }
      }
    end

    let(:invalid_update_params) do
      {
        todo_list_id: todo_list.id,
        id: item.id,
        item: { title: "" }
      }
    end

    context 'with valid parameters' do
      it 'updates the item' do
        patch :update, params: update_params, format: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['msg']).to eq('Item updated successfully')
        expect(item.reload.title).to eq('Updated Title')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the item' do
        patch :update, params: invalid_update_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank")
      end
    end

    context 'when item does not exist' do
      it 'returns not found status' do
        patch :update, params: {
          todo_list_id: todo_list.id,
          id: 999999,
          item: { title: "Updated Title" }
        }, format: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Item not found')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the item' do
      expect {
        delete :destroy, params: { todo_list_id: todo_list.id, id: item.id }, format: :json
      }.to change(Item, :count).by(-1)

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['msg']).to eq('Item deleted successfully')
    end

    it 'returns not found for non-existent item' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: 999999 }, format: :json

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Item not found')
    end
  end

  context 'when todo list does not exist' do
    it 'returns not found status for all actions' do
      get :index, params: { todo_list_id: 999999 }, format: :json
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Todo list not found')

      get :show, params: { todo_list_id: 999999, id: item.id }, format: :json
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Todo list not found')

      post :create, params: { todo_list_id: 999999, item: { title: "New" } }, format: :json
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Todo list not found')

      patch :update, params: { todo_list_id: 999999, id: item.id, item: { title: "Updated" } }, format: :json
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Todo list not found')

      delete :destroy, params: { todo_list_id: 999999, id: item.id }, format: :json
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Todo list not found')
    end
  end
end

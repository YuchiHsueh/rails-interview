require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:todo_list) { create(:todo_list, user: user) }
  let!(:item) { create(:item, todo_list: todo_list, title: 'Test Item') }

  let(:other_user) { create(:user) }
  let(:other_todo_list) { create(:todo_list, user: other_user) }
  let!(:other_item) { create(:item, todo_list: other_todo_list, title: 'Other Item') }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          todo_list_id: todo_list.id,
          item: { title: 'New Item', description: 'Description' }
        }
      end

      it 'creates a new item' do
        expect {
          post :create, params: valid_params, format: :turbo_stream
        }.to change(Item, :count).by(1)
      end

      it 'creates an item associated with the todo list' do
        post :create, params: valid_params, format: :turbo_stream
        expect(Item.last.todo_list).to eq(todo_list)
      end

      it 'returns a turbo stream response' do
        post :create, params: valid_params, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end

      it 'redirects to todo list with HTML format' do
        post :create, params: valid_params
        expect(response).to redirect_to(todo_list)
        expect(flash[:notice]).to eq('Item was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          todo_list_id: todo_list.id,
          item: { title: '' }
        }
      end

      it 'does not create a new item' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Item, :count)
      end

      it 'redirects to todo list with alert' do
        post :create, params: invalid_params
        expect(response).to redirect_to(todo_list)
        expect(flash[:alert]).to eq('Unable to create item. Please check the form.')
      end
    end

    context 'when accessing another user\'s todo list' do
      let(:invalid_access_params) do
        {
          todo_list_id: other_todo_list.id,
          item: { title: 'Hacked Item' }
        }
      end

      it 'redirects to todo list' do
        post :create, params: invalid_access_params
        expect(response).to redirect_to(todo_list_path(other_todo_list))
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:update_params) do
        {
          todo_list_id: todo_list.id,
          id: item.id,
          item: { title: 'Updated Item', completed: true }
        }
      end

      it 'updates the item' do
        patch :update, params: update_params, format: :turbo_stream
        item.reload
        expect(item.title).to eq('Updated Item')
        expect(item.completed).to be true
      end

      it 'returns a turbo stream response' do
        patch :update, params: update_params, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end

      it 'redirects to todo list with HTML format' do
        patch :update, params: update_params
        expect(response).to redirect_to(todo_list)
        expect(flash[:notice]).to eq('Item was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_update_params) do
        {
          todo_list_id: todo_list.id,
          id: item.id,
          item: { title: '' }
        }
      end

      it 'does not update the item' do
        original_title = item.title
        patch :update, params: invalid_update_params
        item.reload
        expect(item.title).to eq(original_title)
      end

      it 'redirects to todo list with alert' do
        patch :update, params: invalid_update_params
        expect(response).to redirect_to(todo_list)
        expect(flash[:alert]).to eq('Unable to update item. Please check the form.')
      end
    end

    context 'when updating another user\'s item' do
      let(:other_item_params) do
        {
          todo_list_id: other_todo_list.id,
          id: other_item.id,
          item: { title: 'Hacked' }
        }
      end

      it 'redirects to todo list' do
        patch :update, params: other_item_params
        expect(response).to redirect_to(todo_list_path(other_todo_list))
      end
    end

    context 'when item is not found' do
      it 'redirects to root path with alert' do
        patch :update, params: { todo_list_id: todo_list.id, id: 999999, item: { title: 'Not Found' } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('The item you requested could not be found.')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when deleting own item' do
      let(:delete_params) do
        {
          todo_list_id: todo_list.id,
          id: item.id
        }
      end

      it 'destroys the item' do
        expect {
          delete :destroy, params: delete_params, format: :turbo_stream
        }.to change(Item, :count).by(-1)
      end

      it 'returns a turbo stream response' do
        delete :destroy, params: delete_params, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end

      it 'redirects to todo list with HTML format' do
        delete :destroy, params: delete_params
        expect(response).to redirect_to(todo_list)
        expect(flash[:notice]).to eq('Item was successfully deleted.')
      end
    end

    context 'when deleting another user\'s item' do
      let(:other_delete_params) do
        {
          todo_list_id: other_todo_list.id,
          id: other_item.id
        }
      end

      it 'redirects to todo list' do
        delete :destroy, params: other_delete_params
        expect(response).to redirect_to(todo_list_path(other_todo_list))
      end
    end

    context 'when item is not found' do
      it 'redirects to root path with alert' do
        delete :destroy, params: { todo_list_id: todo_list.id, id: 999999 }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('The item you requested could not be found.')
      end
    end
  end

  context 'when user is not authenticated' do
    before { sign_out user }

    it 'redirects to login page for create' do
      post :create, params: { todo_list_id: todo_list.id, item: { title: 'New Item' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login page for update' do
      patch :update, params: { todo_list_id: todo_list.id, id: item.id, item: { title: 'Updated' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login page for destroy' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: item.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

require 'rails_helper'

RSpec.describe TodoListsController, type: :controller do
  let(:user) { create(:user) }
  let!(:todo_list) { create(:todo_list, user: user, name: 'Setup RoR project') }
  let(:other_user) { create(:user) }
  let!(:other_todo_list) { create(:todo_list, user: other_user, name: 'Other list') }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns only the user\'s todo lists' do
      get :index
      expect(assigns(:todo_lists)).to include(todo_list)
      expect(assigns(:todo_lists)).not_to include(other_todo_list)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    context 'when accessing own todo list' do
      it 'returns a successful response' do
        get :show, params: { id: todo_list.id }
        expect(response).to be_successful
      end

      it 'assigns the requested todo list' do
        get :show, params: { id: todo_list.id }
        expect(assigns(:todo_list)).to eq(todo_list)
      end
    end

    context 'when accessing another user\'s todo list' do
      it 'redirects to root path with alert' do
        get :show, params: { id: other_todo_list.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('The todo list you requested could not be found.')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { todo_list: { name: 'New Todo List' } } }

      it 'creates a new todo list' do
        expect {
          post :create, params: valid_params, format: :turbo_stream
        }.to change(TodoList, :count).by(1)
      end

      it 'creates a todo list associated with the current user' do
        post :create, params: valid_params, format: :turbo_stream
        expect(TodoList.last.user).to eq(user)
      end

      it 'returns a turbo stream response' do
        post :create, params: valid_params, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end

      it 'redirects to todo lists path with HTML format' do
        post :create, params: valid_params
        expect(response).to redirect_to(todo_lists_path)
        expect(flash[:notice]).to eq('Todo list was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { todo_list: { name: '' } } }

      it 'does not create a new todo list' do
        expect {
          post :create, params: invalid_params, format: :turbo_stream
        }.not_to change(TodoList, :count)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Name' } }

      it 'updates the requested todo list' do
        patch :update, params: { id: todo_list.id, todo_list: new_attributes }
        todo_list.reload
        expect(todo_list.name).to eq('Updated Name')
      end

      it 'redirects to todo lists path' do
        patch :update, params: { id: todo_list.id, todo_list: new_attributes }
        expect(response).to redirect_to(todo_lists_path)
        expect(flash[:notice]).to eq('Todo list was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not update the todo list' do
        original_name = todo_list.name
        patch :update, params: { id: todo_list.id, todo_list: invalid_attributes }
        todo_list.reload
        expect(todo_list.name).to eq(original_name)
      end

      it 'returns unprocessable entity status' do
        patch :update, params: { id: todo_list.id, todo_list: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when updating another user\'s todo list' do
      it 'redirects to root path with alert' do
        patch :update, params: { id: other_todo_list.id, todo_list: { name: 'Hacked' } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('The todo list you requested could not be found.')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when deleting own todo list' do
      it 'destroys the requested todo list' do
        expect {
          delete :destroy, params: { id: todo_list.id }, format: :turbo_stream
        }.to change(TodoList, :count).by(-1)
      end

      it 'returns a turbo stream response' do
        delete :destroy, params: { id: todo_list.id }, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end

      it 'redirects to todo lists path with HTML format' do
        delete :destroy, params: { id: todo_list.id }
        expect(response).to redirect_to(todo_lists_url)
        expect(flash[:notice]).to eq('Todo list was successfully deleted.')
      end
    end

    context 'when deleting another user\'s todo list' do
      it 'redirects to root path with alert' do
        delete :destroy, params: { id: other_todo_list.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('The todo list you requested could not be found.')
      end
    end
  end

  context 'when user is not authenticated' do
    before { sign_out user }

    it 'redirects to login page for index' do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login page for show' do
      get :show, params: { id: todo_list.id }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login page for create' do
      post :create, params: { todo_list: { name: 'New List' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login page for update' do
      patch :update, params: { id: todo_list.id, todo_list: { name: 'Updated' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login page for destroy' do
      delete :destroy, params: { id: todo_list.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'when accessing another user\'s todo list' do
    it 'redirects to root path with alert' do
      get :show, params: { id: other_todo_list.id }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('The todo list you requested could not be found.')
    end
  end
end

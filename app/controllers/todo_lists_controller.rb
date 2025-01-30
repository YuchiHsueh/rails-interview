class TodoListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_list, only: %i[ show edit update destroy ]

  def index
    @todo_lists = current_user.todo_lists.page(params[:page]).per(10)
  end

  def show
  end

  def edit
  end

  def create
    @todo_list = current_user.todo_lists.build(todo_list_params)

    respond_to do |format|
      if @todo_list.save
        format.turbo_stream
        format.html { redirect_to todo_lists_path, notice: 'Todo list was successfully created.' }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('new_todo_list',
            partial: 'form',
            locals: { todo_list: @todo_list })
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @todo_list.update(todo_list_params)
      redirect_to todo_lists_path, notice: 'Todo list was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_list.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo_list) }
      format.html { redirect_to todo_lists_url, notice: 'Todo list was successfully destroyed.' }
    end
  end

  private

  def set_todo_list
    @todo_list = current_user.todo_lists.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end

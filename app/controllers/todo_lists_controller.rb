class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[ show edit update destroy ]

  def index
    @todo_lists = TodoList.page(params[:page]).per(10)
  end

  def show
  end

  def edit
  end

  def create
    @todo_list = TodoList.new(todo_list_params)

    respond_to do |format|
      if @todo_list.save
        format.html { redirect_to @todo_list, notice: "Todo list created successfully" }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("todo_lists", partial: "todo_list", locals: { todo_list: @todo_list }),
            turbo_stream.update("new_todo_list", partial: "form", locals: { todo_list: TodoList.new })
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream.update("new_todo_list",
            partial: "form",
            locals: { todo_list: @todo_list })
        end
      end
    end
  end

  def update
    if @todo_list.update(todo_list_params)
      redirect_to @todo_list, notice: "Todo list updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_list.destroy

    respond_to do |format|
      format.html { redirect_to todo_lists_url, notice: "Todo list deleted successfully" }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@todo_list)
      end
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end

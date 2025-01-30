class Api::TodoListsController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :todo_list_not_found
  before_action :set_todo_list, only: %i[ show update destroy ]

  def index
    @todo_lists = TodoList.page(params[:page]).per(params[:per_page] || 10)
    render json: {
      todo_lists: @todo_lists,
      total_pages: @todo_lists.total_pages,
      current_page: @todo_lists.current_page,
      total_count: @todo_lists.total_count
    }, status: :ok
  end

  def show
    render json: @todo_list, status: :ok
  end

  def create
    @todo_list = TodoList.new(todo_list_params)
    if @todo_list.save
      render json: {
        msg: "Todo list created successfully",
        todo_list: @todo_list
      }, status: :created
    else
      error_handler(@todo_list.errors)
    end
  end

  def update
    if @todo_list.update(todo_list_params)
      render json: {
        msg: "Todo list updated successfully",
        todo_list: @todo_list
      }, status: :ok
    else
      error_handler(@todo_list.errors)
    end
  end

  def destroy
    @todo_list.destroy
    render json: {
      msg: "Todo list deleted successfully"
    }, status: :ok
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end

  def error_handler(errors)
    render json: { errors: errors.full_messages }, status: :unprocessable_entity
  end

  def todo_list_not_found
    render json: { error: "Todo list not found" }, status: :not_found
  end
end

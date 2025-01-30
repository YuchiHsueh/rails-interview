class Api::ItemsController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :item_not_found
  before_action :set_todo_list
  before_action :set_item, only: %i[ show update destroy ]

  def index
    @items = @todo_list.items.page(params[:page]).per(params[:per_page] || 10)
    render json: {
      items: @items,
      total_pages: @items.total_pages,
      current_page: @items.current_page,
      total_count: @items.total_count
    }, status: :ok
  end

  def show
    render json: {
      item: @item
    }, status: :ok
  end

  def create
    @item = @todo_list.items.build(item_params)

    if @item.save
      render json: {
        msg: "Item created successfully",
        item: @item
      }, status: :created
    else
      error_handler(@item.errors)
    end
  end

  def update
    if @item.update(item_params)
      render json: {
        msg: "Item updated successfully",
        item: @item
      }, status: :ok
    else
      error_handler(@item.errors)
    end
  end

  def destroy
    @item.destroy
    render json: {
      msg: "Item deleted successfully"
    }, status: :ok
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_item
    @item = @todo_list.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :description)
  end

  def error_handler(errors)
    render json: { errors: errors.full_messages }, status: :unprocessable_entity
  end

  def item_not_found
    render json: { error: "Item not found" }, status: :not_found
  end
end

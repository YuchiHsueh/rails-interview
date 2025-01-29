class Api::ItemsController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :item_not_found
  before_action :set_todo_list, only: [:index, :create]
  before_action :set_item, only: [:update, :destroy]

  def index
    @items = @todo_list.items.page(params[:page]).per(params[:per_page] || 10)
    render json: {
      items: @items,
      total_pages: @items.total_pages,
      current_page: @items.current_page,
      total_count: @items.total_count
    }, status: :ok
  end

  def create
    @item = @todo_list.items.build(item_params)

    if @item.save
      render json: @item, status: :ok
    else
      error_handler(@item.errors)
    end
  end

  def update
    @item = Item.find(params[:id])

    if @item.update(item_params)
      render json: @item, status: :ok
    else
      error_handler(@item.errors)
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    head :ok
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_item
    @item = Item.find(params[:id])
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

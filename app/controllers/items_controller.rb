class ItemsController < ApplicationController
  before_action :set_todo_list

  def create
    @item = @todo_list.item.new(item_params)
    if @item.save
      redirect_to api_todo_list(@todo_list)
    else
      redirect_to api_todo_list(@todo_list), status: :unprocessable_entity, notice: "Couldn't create the item"
    end
  end

  private

  def todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :description)
  end
end

class ItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_item, only: %i[update destroy]

  def create
    @item = @todo_list.items.build(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to @todo_list, notice: 'Item was successfully created.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("items_list", partial: "items/list", locals: { todo_list: @todo_list }),
            turbo_stream.update("new_item", partial: "items/form", locals: { todo_list: @todo_list, item: Item.new })
          ]
        end
      else
        format.html { redirect_to @todo_list, alert: 'Error creating item.' }
        format.turbo_stream do
          render turbo_stream.update("new_item",
            partial: "items/form",
            locals: { todo_list: @todo_list, item: @item })
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @todo_list, notice: 'Item was successfully updated.' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            @item,
            partial: "items/item",
            locals: { todo_list: @todo_list, item: @item }
          )
        }
      else
        format.html { redirect_to @todo_list, alert: 'Error updating item.' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            @item,
            partial: "items/item",
            locals: { todo_list: @todo_list, item: @item }
          )
        }
      end
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to @todo_list, notice: 'Item was successfully deleted.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@item) }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_item
    @item = @todo_list.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :description, :completed)
  end
end

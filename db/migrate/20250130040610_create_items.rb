class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :completed, default: false, null: false
      t.references :todo_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end

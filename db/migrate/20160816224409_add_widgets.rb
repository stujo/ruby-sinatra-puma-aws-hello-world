class AddWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.string :name, index: true, unique: true
      t.timestamps null: false
    end
  end
end

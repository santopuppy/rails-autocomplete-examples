class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants do |t|
      t.belongs_to :product, null: false
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end

class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.belongs_to :product, null: false

      t.text :body, null: false
      t.timestamps null: false
    end
  end
end

class AddTrigger < ActiveRecord::Migration

  require "#{Rails.root}/lib/product_create_trigger"
  require "#{Rails.root}/lib/product_association_trigger"
  require "#{Rails.root}/lib/product_association_destroy_trigger"

  def up
    add_column :products, :autocomplete_tsvector, :tsvector
    add_index :products, :autocomplete_tsvector, using: :gin
    
    ProductCreateTrigger.invoke
    ProductAssociationTrigger.invoke
    ProductAssociationDestroyTrigger.invoke  end

  def down
    remove_column :products, :autocomplete_tsvector

    execute <<-SQL
      DROP TRIGGER update_autocomplete ON products;

      DROP TRIGGER touch_product_trigger ON variants;
      DROP TRIGGER touch_product_trigger ON metadata;

      DROP TRIGGER touch_product_on_delete_trigger ON variants;
      DROP TRIGGER touch_product_on_delete_trigger ON metadata;

      DROP FUNCTION touch_products_on_delete();
      DROP FUNCTION product_autocomplete_trigger();
      DROP FUNCTION touch_products();
    SQL
  end
end

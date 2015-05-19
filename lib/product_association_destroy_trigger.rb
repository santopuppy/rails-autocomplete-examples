module ProductAssociationDestroyTrigger
  def self.invoke
    connection = ActiveRecord::Base.connection
    
    # Of course, we have to handle DELETE events don't we? ;)
    connection.execute <<-SQL
      -- Same concept as above, except here we use the OLD keyword instead of new.
      -- We want to reference and return the old object here because after a delete,
      -- there is no NEW object to refer to.
      -- For more info on OLD/NEW keywords, refer to
      -- http://www.postgresql.org/docs/9.1/static/plpgsql-trigger.html
      CREATE OR REPLACE FUNCTION touch_products_on_delete() RETURNS trigger as $$
      BEGIN
        UPDATE products SET updated_at = old.updated_at
        WHERE products.id = old.product_id;
        return old;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER touch_product_on_delete_trigger AFTER DELETE
      ON variants
      FOR EACH ROW EXECUTE PROCEDURE touch_products_on_delete();

      CREATE TRIGGER touch_product_on_delete_trigger AFTER DELETE
      ON metadata
      FOR EACH ROW EXECUTE PROCEDURE touch_products_on_delete();
    SQL
  end
end
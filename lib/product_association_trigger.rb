module ProductAssociationTrigger
  def self.invoke
    connection = ActiveRecord::Base.connection
    
    # Here we create a function and trigger for when the associated variant and
    # metadata is created or updated
    connection.execute <<-SQL
      CREATE OR REPLACE FUNCTION touch_products() RETURNS trigger as $$
      BEGIN
        -- In this trigger function we simply update the updated_at column
        -- of the product that is associated with the variant/metadatum.

        -- The key here is we want to set off an UPDATE event on the products
        -- so that its own trigger gets fired. You could do whatever you want in the
        -- function, as long as you set off an UPDATE event, so be creative! ;)
        UPDATE products SET updated_at = new.updated_at
        WHERE products.id = new.product_id;
        return new;
      END;
      $$ LANGUAGE plpgsql;

      -- Trigger AFTER an insert or update event. It is very important 
      -- to set tne trigger function after an UPDATE or INSERT event where
      -- we are 100% sure that the updated_at column is already populated.
      CREATE TRIGGER touch_product_trigger AFTER INSERT OR UPDATE
      ON variants
      FOR EACH ROW EXECUTE PROCEDURE touch_products();

      -- Same as above, we attach the same function but on a different table.
      -- We create the trigger for the metadata here.
      CREATE TRIGGER touch_product_trigger AFTER INSERT OR UPDATE
      ON metadata
      FOR EACH ROW EXECUTE PROCEDURE touch_products();
    SQL
  end
end
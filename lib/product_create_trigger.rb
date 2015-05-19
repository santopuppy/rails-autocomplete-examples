module ProductCreateTrigger
  def self.invoke
    connection = ActiveRecord::Base.connection

    # Function and trigger for when a product is created or updated
    connection.execute <<-SQL

      -- Create the function that we use for the trigger
      CREATE OR REPLACE FUNCTION product_autocomplete_trigger() RETURNS trigger as $$

      DECLARE
        -- Here we declare our variables. Since we are going to store a single row into
        -- a variable we declare that our variables are ROWTYPE. Row types can only store
        -- a single row. If your query has more than one result an exception will
        -- occur. For more info about this, visit
        -- http://www.postgresql.org/docs/9.3/static/plpgsql-declarations.html#PLPGSQL-DECLARATION
        variant variants%ROWTYPE;
        metadatum metadata%ROWTYPE;

      BEGIN
        -- We use store the single row result of our query on the variables we
        -- declared above. For more information visit
        -- http://www.postgresql.org/docs/9.3/static/plpgsql-declarations.html#PLPGSQL-DECLARATION-ROWTYPES
        SELECT * INTO variant FROM variants WHERE variants.product_id = new.id;
        SELECT * INTO metadatum FROM metadata WHERE metadata.product_id = new.id;

        -- We set the value for autocomplete_tsvector column. Visit
        -- http://www.postgresql.org/docs/9.3/static/textsearch-controls.html#TEXTSEARCH-PARSING-DOCUMENTS
        -- for more info
        new.autocomplete_tsvector := (
          setweight(to_tsvector('simple', coalesce(new.name, '')), 'A') ||
          setweight(to_tsvector('simple', coalesce(variant.name, '')), 'B') ||
          setweight(to_tsvector('simple', coalesce(metadatum.body, '')), 'B')
        );
        return new;
      END;
      $$ LANGUAGE plpgsql;
      -- End of our function declaration

      -- Create the trigger on the products table
      -- For some reason if I use 'AFTER INSERT OR UPDATE' the trigger is
      -- not triggered. So here I use 'BEFORE INSERT OR UPDATE'. Someone
      -- please tell me why this is so.

      -- PostgreSQL official docs on triggers:
      -- http://www.postgresql.org/docs/9.3/static/sql-createtrigger.html
      CREATE TRIGGER update_autocomplete BEFORE INSERT OR UPDATE
      ON products
      FOR EACH ROW EXECUTE PROCEDURE product_autocomplete_trigger();

    SQL
  end
end
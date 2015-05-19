require "#{Rails.root}/lib/product_create_trigger"
require "#{Rails.root}/lib/product_association_trigger"
require "#{Rails.root}/lib/product_association_destroy_trigger"

# We enhance the rake task for schema loading because custom SQL is not loaded in
# schema.rb. This will make it compatible with tests.
namespace :db do

  Rake::Task['db:schema:load'].enhance do
    ProductCreateTrigger.invoke
    ProductAssociationTrigger.invoke
    ProductAssociationDestroyTrigger.invoke
  end
end
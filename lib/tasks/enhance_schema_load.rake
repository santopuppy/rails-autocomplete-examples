require "#{Rails.root}/lib/product_create_trigger"
require "#{Rails.root}/lib/product_association_trigger"
require "#{Rails.root}/lib/product_association_destroy_trigger"

namespace :db do

  Rake::Task['db:schema:load'].enhance do
    ProductCreateTrigger.invoke
    ProductAssociationTrigger.invoke
    ProductAssociationDestroyTrigger.invoke
  end
end
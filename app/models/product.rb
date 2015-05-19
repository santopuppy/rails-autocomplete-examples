class Product < ActiveRecord::Base

  include PgSearch

  has_one :variant
  has_one :metadatum

  searchable do
    text        :name
    autosuggest :name
  end

  pg_search_scope :autocomplete,
                against: :name,
                using: {tsearch: {prefix: true} }

  pg_search_scope :autocomplete_with_association, associated_against: {
      variant: :name,
      metadatum: :body
    },
    using: {tsearch: {prefix: true} }

  pg_search_scope :autocomplete_with_association_using_tsvector,
                  against: :name,
                  using: {tsearch: {prefix: true, tsvector_column: 'autocomplete_tsvector'} }


  # Take caution when running this, the loop executes 100,000 times!
  def self.populate
    100_000.times do |x|
      name_variants = [
        'hotdog', 'cheese', 'mustard', 'barbeque sauce', 'aioli', 'ajvar', 'chimichurri', 'guacamole', 'ketchup', 'mayonnaise',
        'olive oil', 'pickles', 'pepper', 'pechay', 'cabbage', 'tomato', 'salt', 'salsa', 'sesame oil', 'soy sauce'
      ]

      body = [name_variants.sample, name_variants.sample, name_variants.sample].join(' ')

      product = Product.create(name: "Product #{1} #{name_variants.sample}")
      Variant.create(name: name_variants.sample, product_id: product.id)
      Metadatum.create(body: body, product_id: product.id)
    end
  end

end

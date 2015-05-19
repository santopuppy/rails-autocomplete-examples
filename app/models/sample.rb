class Sample

  class << self

    def sample1
      Product.where("name like '%Hotdog%'")
    end

    def sample2
      Product.where("name like '%hot%'")
    end

    def sample3
      query_term = "hotdog"
      query = "name_as:#{query_term}"

      Product.search do
        adjust_solr_params do |params|
          params[:fq] << query
        end
      end.results

    end

    def sample4
      query_term = "hot"
      query = "name_as:#{query_term}"

      Product.search do
        adjust_solr_params do |params|
          params[:fq] << query
        end
      end.results

    end

    def sample5
      Product.autocomplete('hot')
    end

    def sample6
      Product.autocomplete_with_association('hot')
    end

    def sample7
      Product.autocomplete_with_association_using_tsvector('hot')
    end

  end 
end
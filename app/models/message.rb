require 'elasticsearch/model'

class Message < ApplicationRecord

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  searchkick

  belongs_to :chat, counter_cache: true
  # include Searchable

  def self.search(query, page: 1)
    size = 10
    from = (page - 1) * size  # Calculate the correct 'from' value
  
    __elasticsearch__.search(
      query: {
        multi_match: {
          query: query,
          fields: ['body']
        }
      },
      size: size,
      from: from
    )
  end
  
  
  
  
end

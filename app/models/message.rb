class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :chat, counter_cache: true

  validates :lock_version, presence: true

  validates :body, presence: true, length: { minimum: 1, maximum: 20 }

  def self.search(query, page: 1)
    size = 10
    from = (page - 1) * size
  
    __elasticsearch__.search(
      query: {
        wildcard: {
          body: {
            value: "*#{query}*"
          }
        }
      },
      size: size,
      from: from
    )
  end

  def update_with_optimistic_lock(attributes)
    update!(attributes)
  rescue ActiveRecord::StaleObjectError
    # Handle the conflict, e.g., by reloading the record and trying again
    reload
    retry
  end
end

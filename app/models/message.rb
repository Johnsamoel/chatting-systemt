class Message < ApplicationRecord

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :chat, counter_cache: true
  include Searchable
end

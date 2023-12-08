class Message < ApplicationRecord

  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks

  # searchkick

  belongs_to :chat, counter_cache: true

end

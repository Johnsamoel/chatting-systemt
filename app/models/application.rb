class Application < ApplicationRecord
    has_many :chats, counter_cache: true, dependent: :destroy_async
    include WillPaginate::CollectionMethods
    validates :name, presence: true, length: { minimum: 4 }
  end
  
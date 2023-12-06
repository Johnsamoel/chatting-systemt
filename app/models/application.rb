class Application < ApplicationRecord
    has_many :chats, counter_cache: true

    validates :name, presence: true ,  length: { minimum: 4 }
end

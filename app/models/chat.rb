class Chat < ApplicationRecord
  belongs_to :application, counter_cache: true
  has_many :messages
  validates :chat_name, presence: true, length: { minimum: 4 }

end

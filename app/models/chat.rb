class Chat < ApplicationRecord
 
  belongs_to :application, counter_cache: true
 
  has_many :messages
  
  # validates :chat_name, presence: true, length: { minimum: 4 }
  
  validates :lock_version, presence: true

  def update_with_optimistic_lock(attributes)
    update!(attributes)
  rescue ActiveRecord::StaleObjectError
    # Handle the conflict, e.g., by reloading the record and trying again
    reload
    retry
  end
end

class AddAutoIncrementToChatNumber < ActiveRecord::Migration[7.1]
  def change
    # Add a new column `chat_number` with type INTEGER
    add_column :chats, :chat_number, :integer, null: false, default: 1

    # Update existing chats with sequential chat numbers
    Chat.find_each.with_index do |chat, index|
      chat.update_column(:chat_number, index + 1)
    end

    # Remove the old column `number`
    remove_column :chats, :number
  end
end

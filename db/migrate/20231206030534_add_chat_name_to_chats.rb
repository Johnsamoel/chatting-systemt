class AddChatNameToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :chat_name, :string, limit: 20, null: false
  end
end

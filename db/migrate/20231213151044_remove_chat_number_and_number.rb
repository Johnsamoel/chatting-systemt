class RemoveChatNumberAndNumber < ActiveRecord::Migration[7.1]
  def change
    remove_column :chats, :chat_number, :integer
    remove_column :messages, :number, :integer
  end
end

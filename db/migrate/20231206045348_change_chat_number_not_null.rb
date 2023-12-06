class ChangeChatNumberNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column :chats, :number, :integer, default: 1, null: false
    Chat.where(number: nil).update_all(number: 1)
  end
end

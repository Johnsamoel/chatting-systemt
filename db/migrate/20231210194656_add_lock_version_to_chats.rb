class AddLockVersionToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :lock_version, :integer, default: 0, null: false
  end
end

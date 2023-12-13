class ModifyDefaultValuesForCounts < ActiveRecord::Migration[7.1]
  def change
    change_column_default :chats, :messages_count, from: nil, to: 0
    change_column_default :applications, :chats_count, from: nil, to: 0
  end
end

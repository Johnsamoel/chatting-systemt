class ModifyChatsAndApplications < ActiveRecord::Migration[7.1]
  def change
    change_table :applications do |t|
      t.integer :chats_count, default: 1
    end

    change_table :chats do |t|
      t.integer :number, default: 1
      t.index [:application_id, :number], unique: true, name: 'index_chats_on_application_id_and_number'
    end
  end
end

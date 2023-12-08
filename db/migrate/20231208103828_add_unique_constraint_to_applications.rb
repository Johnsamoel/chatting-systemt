class AddUniqueConstraintToApplications < ActiveRecord::Migration[7.1]
  def change
    add_index :applications, :name, unique: true
  end
end

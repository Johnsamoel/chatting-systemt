class AddColumnsToMessages < ActiveRecord::Migration[7.1]
  def change
    def change
      add_column :messages, :body, :text
      add_column :messages, :number, :integer
    end
  end
end

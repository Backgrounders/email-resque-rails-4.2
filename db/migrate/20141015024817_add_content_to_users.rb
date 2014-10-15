class AddContentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :content, :text
  end
end

class AddFavoritesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :favorites, :string, array: true, default: []
  end
end

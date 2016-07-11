class FixColumnName < ActiveRecord::Migration[5.0]
  def change
      change_table :users do |t|
      t.rename :name, :first_name
      add_column :users, :last_name, :string
    end
  end
end

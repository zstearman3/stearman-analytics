class AddVarianceToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :variance, :decimal
    add_column :teams, :homeadv, :decimal
    add_column :teams, :awayadv, :decimal
  end
end

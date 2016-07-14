class AddIndexToTeamsSchoolName < ActiveRecord::Migration[5.0]
  def change
    add_index :teams, :school_name, unique: true
  end
end

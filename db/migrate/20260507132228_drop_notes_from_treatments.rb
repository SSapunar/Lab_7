class DropNotesFromTreatments < ActiveRecord::Migration[8.1]
  def change
    remove_column :treatments, :notes, :string
  end
end
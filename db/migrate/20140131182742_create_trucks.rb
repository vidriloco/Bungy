class CreateTrucks < ActiveRecord::Migration
  def change
    create_table :trucks do |t|
      t.string      :plate
      t.string      :name
      t.integer     :company_id
      t.timestamps
    end
  end
end

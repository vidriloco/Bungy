class CreateGpsUnits < ActiveRecord::Migration
  def change
    create_table :gps_units do |t|
      t.string            :identifier
      t.string            :rmuid
      t.text              :details
      t.integer           :truck_id
      t.integer           :company_id
      t.timestamps
    end
    
    
    add_index :gps_units, :identifier, :unique => true, :name => 'gps_units_unique_identifier'
    add_index :gps_units, [:identifier, :truck_id, :company_id], :unique => true, :name => 'gps_units_unique_assignment'
  end
end

class CreateInstants < ActiveRecord::Migration
  def change
    create_table :instants do |t|
      t.point           :coordinates, :geographic => true
      t.decimal         :speed
      t.integer         :gps_unit_id
      t.decimal         :heading
      t.datetime        :measurement_time
      t.decimal         :altitude
      t.integer         :transmission_reason
      t.integer         :transmission_reason_specific_data
      t.timestamps
    end
  end
end

class CreateCheckpoints < ActiveRecord::Migration
  def change
    create_table :checkpoints do |t|
      t.string        :title
      t.point         :coordinates, :geographic => true
      t.integer       :expected_timing
      t.integer       :route_id
      t.timestamps
    end
  end
end

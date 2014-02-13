class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string        :name
      t.text          :details
      t.integer       :company_id
      t.timestamps
    end
  end
end

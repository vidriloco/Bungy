class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string        :name
      t.string        :website
      # TODO: Add logo-pic 
      t.timestamps
    end
  end
end
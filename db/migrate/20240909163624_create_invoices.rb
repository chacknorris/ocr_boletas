class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.string :image
      t.text :extracted_text
      t.date :date
      t.decimal :total

      t.timestamps
    end
  end
end

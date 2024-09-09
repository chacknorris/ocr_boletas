json.extract! invoice, :id, :image, :extracted_text, :date, :total, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)

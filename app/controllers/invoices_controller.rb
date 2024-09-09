class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update destroy ]

  # GET /invoices or /invoices.json
  def index
    @invoices = Invoice.all
  end

  # GET /invoices/1 or /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        # Procesar la imagen con OCR usando Tesseract
        if @invoice.image.attached?
          # Descargar la imagen
          downloaded_image = @invoice.image.download

          # Procesar la imagen con Tesseract
          ocr_result = RTesseract.new(downloaded_image)
          extracted_text = ocr_result.to_s

          # Actualizar la factura con el texto extraído
          @invoice.update(extracted_text: extracted_text)

          # Ejemplo: extraer fecha y total de la factura
          if extracted_text.match(/\d{2}\/\d{2}\/\d{4}/)
            @invoice.update(date: extracted_text.match(/\d{2}\/\d{2}\/\d{4}/)[0])
          end
          if extracted_text.match(/\$\d+(\.\d{2})?/)
            @invoice.update(total: extracted_text.match(/\$\d+(\.\d{2})?/)[0].gsub('$', '').to_f)
          end
        end

        format.html { redirect_to invoice_url(@invoice), notice: "Invoice was successfully created and processed." }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to invoice_url(@invoice), notice: "Invoice was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.destroy!

    respond_to do |format|
      format.html { redirect_to invoices_url, notice: "Invoice was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(:image, :extracted_text, :date, :total)
  end
end
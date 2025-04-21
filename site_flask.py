from flask import Flask, request, render_template_string
import PyPDF2
import os

app = Flask(__name__)
UPLOAD_FOLDER = './uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/", methods=["GET", "POST"])
def upload_pdf():
    if request.method == "POST":
        pdf_file = request.files["pdf"]
        if not pdf_file.filename.endswith(".pdf"):
            return "Carica solo file PDF!"
        
        file_path = os.path.join(UPLOAD_FOLDER, pdf_file.filename)
        pdf_file.save(file_path)

        # Legge il contenuto del PDF (solo la prima pagina per semplicità)
        with open(file_path, "rb") as f:
            reader = PyPDF2.PdfReader(f)
            text = reader.pages[0].extract_text() if reader.pages else "Nessun contenuto"

        #  Mostra il contenuto del PDF in una pagina HTML senza escaping!
        return render_template_string(f"""
            <h1>Contenuto del PDF</h1>
            <p>{text}</p>
            <a href="/">Carica un altro PDF</a>
        """)
    
    return '''
        <h1>Carica un PDF</h1>
        <form method="POST" enctype="multipart/form-data">
            <input type="file" name="pdf" />
            <input type="submit" value="Carica" />
        </form>
    '''

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

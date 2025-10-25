from fastapi import FastAPI, Body
import google.generativeai as genai

# Configura tu API key de Gemini
genai.configure(api_key="AIzaSyB9JIhKFx4cMnI55j2qGYGT1wFoUoeCGSw")

# Crea el cliente del modelo
model = genai.GenerativeModel("gemini-2.0-flash")

# Inicializa la app FastAPI
app = FastAPI(title="API Gemini", description="API que interactúa con Gemini", version="1.0")

@app.post("/ask")
def ask_gemini(prompt: str = Body(..., embed=True)):
    """
    Endpoint para enviar un prompt a Gemini.
    Ejemplo de JSON a enviar:
    {
        "prompt": "Explícame cómo funciona la inteligencia artificial en pocas palabras."
    }
    """
    try:
        response = model.generate_content("Dame una respuesta muy breve a los siguiente: " + prompt)
        return {"response": response.text}
    except Exception as e:
        return {"error": str(e)}

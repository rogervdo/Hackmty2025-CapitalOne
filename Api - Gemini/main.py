from fastapi import FastAPI, Body
import google.generativeai as genai
import mysql.connector
from datetime import datetime


genai.configure(api_key="AIzaSyB9JIhKFx4cMnI55j2qGYGT1wFoUoeCGSw")
model = genai.GenerativeModel("gemini-2.0-flash")


db_config = {
    "host": "capital-one-mysql-2a76c2d1-tec-a639.f.aivencloud.com",
    "user": "avnadmin",
    "password": "AVNS_aITyrcv-CLHDbOSVdTO",
    "database": "CapitalOne",  
    "port": 21909,

}

def get_db_connection():
    return mysql.connector.connect(**db_config)


app = FastAPI(title="CapitalOne + Gemini API", version="3.0")


@app.post("/emojis")
def ask_gemini(prompt: str = Body(..., embed=True)):
    """
    Devuelve un emoji según el tipo de gasto.
    """
    try:
        base_prompt = (
            "Categorizador de gastos según emojis: "
            "Viajes ✈️; Comidas 🍽️; Compras 🛍️; Entretenimiento 🍿; Transporte ⛽; "
            "Supermercado 🛒; Hogar 🏠; Salud ⚕️; Educación 📚; Deporte 🏋️‍♀️; "
            "Tecnología 💻; Moda 👕; Cuidado Personal 💄; Mascotas 🐾; "
            "Regalos 🎁; Ahorros 📈; Bancos 🏦; Efectivo 🏧; Hobbies 🎮; Automóvil 🛠️; "
            "Por defecto 🏷️. Devuelve solo el emoji correspondiente a: "
            f"{prompt}"
        )
        response = model.generate_content(base_prompt)
        return {"emoji": response.text.strip()}
    except Exception as e:
        return {"error": str(e)}


@app.post("/gastos/nuevo")
def nuevo_gasto(
    chargeName: str = Body(...),
    amount: float = Body(...),
    location: str = Body(...),
    category: str = Body(...),
    utility: str = Body(...),
    user: int = Body(...)
):

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            INSERT INTO Gastos (chargeName, amount, timeStamp, location, category, utility, user)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        values = (chargeName, amount, timestamp, location, category, utility, user)

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return {"message": "✅ Gasto agregado correctamente."}
    except Exception as e:
        return {"error": str(e)}


@app.get("/gastos")
def obtener_gastos():
    """
    Devuelve todos los gastos con su usuario asociado.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                U.user AS user_name, 
                G.chargeName, 
                G.amount, 
                G.timeStamp, 
                G.location,
                G.category,
                G.utility
            FROM 
                Usuario U
            INNER JOIN 
                Gastos G ON U.idUser = G.user
            ORDER BY 
                U.user, G.timeStamp DESC;
        """

        cursor.execute(query)
        data = cursor.fetchall()

        cursor.close()
        conn.close()

        return {"gastos": data}
    except Exception as e:
        return {"error": str(e)}


@app.get("/gastos/{user_id}")
def obtener_gastos_usuario(user_id: int):
    """
    Devuelve todos los gastos de un usuario específico.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                G.chargeName, 
                G.amount, 
                G.timeStamp, 
                G.location,
                G.category,
                G.utility
            FROM 
                Gastos G
            WHERE 
                G.user = %s
            ORDER BY 
                G.timeStamp DESC
        """
        
        cursor.execute(query, (user_id,))
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return {"gastos": results}
    except Exception as e:
        return {"error": str(e)}

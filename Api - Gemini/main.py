from fastapi import FastAPI, Body
from datetime import datetime
import google.generativeai as genai
import mysql.connector
import json

genai.configure(api_key="AIzaSyB9JIhKFx4cMnI55j2qGYGT1wFoUoeCGSw")
model = genai.GenerativeModel("gemini-2.0-flash")

db_config = {
    "host": "capital-one-mysql-2a76c2d1-tec-a639.f.aivencloud.com",
    "user": "avnadmin",
    "password": "AVNS_aITyrcv-CLHDbOSVTO",
    "database": "CapitalOne",  
    "port": 21909,
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

app = FastAPI(title="CapitalOne + Gemini API", version="5.2")

# ------------------------------
# Endpoint: Emojis
# ------------------------------
@app.post("/emojis")
def ask_gemini(prompt: str = Body(..., embed=True)):
    try:
        base_prompt = (
            "Expense Categorizer based on Emojis: "
            "Travel ✈️; Food 🍽️; Shopping 🛍️; Entertainment 🍿; Transport ⛽; "
            "Groceries 🛒; Home 🏠; Health ⚕️; Education 📚; Sport 🏋️‍♀️; "
            "Technology 💻; Fashion 👕; Personal Care 💄; Pets 🐾; "
            "Gifts 🎁; Savings 📈; Banking 🏦; Cash 🏧; Hobbies 🎮; Automotive 🛠️; "
            "Default 🏷️. Return the corresponding emoji and its category in JSON format "
            f"with only these two data points: {prompt}"
        )
        response = model.generate_content(base_prompt)
        text = response.text.strip()
        return {"emoji": text.split('"emoji":')[1].split(',')[0].replace('"','').strip(),
                "category": text.split('"category":')[1].split('}')[0].replace('"','').strip()}
    except Exception as e:
        return {"error": str(e)}

# ------------------------------
# Endpoint: Registrar referencia de gastos
# ------------------------------
@app.post("/gastos/referencia")
def registrar_referencia(
    user_id: int = Body(...),
    reference: dict = Body(...)
):
    """
    Guarda la referencia de clasificación de gastos para un usuario.
    reference = {
        "aligned": ["Monthly Internet Bill", "Groceries at Walmart"],
        "regret": ["Dinner at Italian Restaurant", "Concert Ticket"]
    }
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "ALTER TABLE Usuario ADD COLUMN IF NOT EXISTS reference TEXT"
        )  # crea columna si no existe
        cursor.execute(
            "UPDATE Usuario SET reference=%s WHERE idUser=%s",
            (json.dumps(reference), user_id)
        )
        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "✅ Referencia de gastos registrada correctamente."}
    except Exception as e:
        return {"error": str(e)}

# ------------------------------
# Endpoint: Nuevo gasto
# ------------------------------
@app.post("/gastos/nuevo")
def nuevo_gasto(
    chargeName: str = Body(...),
    amount: float = Body(...),
    location: str = Body(...),
    category: str = Body(...),
    utility: str = Body(...),
    user: int = Body(...)
):
    """
    Inserta un gasto, ajusta utility basado en referencia, y calcula progreso de meta con feedback.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Obtener referencia del usuario
        cursor.execute("SELECT reference FROM Usuario WHERE idUser=%s", (user,))
        ref = cursor.fetchone()
        reference = {"aligned": [], "regret": []}
        if ref and ref['reference']:
            reference = json.loads(ref['reference'])

        # Ajustar utility según referencia
        if chargeName in reference.get("aligned", []):
            utility = "aligned"
        elif chargeName in reference.get("regret", []):
            utility = "regret"

        # Insertar gasto
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cursor.execute(
            """INSERT INTO Gastos (chargeName, amount, timeStamp, location, category, utility, user)
               VALUES (%s, %s, %s, %s, %s, %s, %s)""",
            (chargeName, amount, timestamp, location, category, utility, user)
        )
        conn.commit()

        # Obtener la meta más reciente
        cursor.execute("SELECT * FROM Metas WHERE user=%s ORDER BY start_date DESC LIMIT 1", (user,))
        meta = cursor.fetchone()
        cursor.execute("SELECT chargeName, amount, category, utility FROM Gastos WHERE user=%s", (user,))
        gastos = cursor.fetchall()
        cursor.close()
        conn.close()

        numerical_progress = {}
        feedback = None
        if meta and gastos:
            total_gastado = sum(g['amount'] for g in gastos)
            total_regret = sum(g['amount'] for g in gastos if g['utility'] == 'regret')
            progreso_pct = min((total_gastado / meta['goal_amount']) * 100, 100)
            monto_restante = max(meta['goal_amount'] - total_gastado, 0)

            gastos_text = "\n".join([f"{g['chargeName']} - ${g['amount']} - {g['category']} - {g['utility']}" for g in gastos])
            prompt = (
                f"Analiza estos gastos de un usuario y genera tips de mejora financiera. "
                f"Indica qué gastos no deberían haberse hecho, en qué ha mejorado y consejos prácticos. "
                f"Devuélvelo en JSON con campos: 'regrets', 'improvements', 'tips'.\n\n"
                f"Gastos:\n{gastos_text}"
            )
            response = model.generate_content(prompt)
            feedback = response.text.strip()

            numerical_progress = {
                "total_spent": total_gastado,
                "total_regret": total_regret,
                "progress_percent": progreso_pct,
                "amount_remaining": monto_restante
            }

        return {
            "message": "✅ Gasto agregado correctamente.",
            "meta_progress": {
                "meta": meta,
                "numerical_progress": numerical_progress,
                "feedback": feedback
            } if meta else None
        }

    except Exception as e:
        return {"error": str(e)}

# ------------------------------
# Endpoint: Obtener gastos
# ------------------------------
@app.get("/gastos")
def obtener_gastos():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """SELECT U.user AS user_name, G.chargeName, G.amount, G.timeStamp, G.location, G.category, G.utility
               FROM Usuario U
               INNER JOIN Gastos G ON U.idUser = G.user
               ORDER BY U.user, G.timeStamp DESC"""
        )
        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return {"gastos": data}
    except Exception as e:
        return {"error": str(e)}

@app.get("/gastos/{user_id}")
def obtener_gastos_usuario(user_id: int):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """SELECT chargeName, amount, timeStamp, location, category, utility
               FROM Gastos
               WHERE user=%s
               ORDER BY timeStamp DESC""",
            (user_id,)
        )
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return {"gastos": results}
    except Exception as e:
        return {"error": str(e)}

# ------------------------------
# Endpoint: Metas
# ------------------------------
@app.post("/metas/nueva")
def nueva_meta(
    user_id: int = Body(...),
    name: str = Body(...),
    description: str = Body(...),
    goal_amount: float = Body(...),
    start_date: str = Body(...),
    end_date: str = Body(...)
):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Metas (user, name, description, goal_amount, start_date, end_date) VALUES (%s,%s,%s,%s,%s,%s)",
            (user_id, name, description, goal_amount, start_date, end_date)
        )
        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "✅ Meta creada correctamente."}
    except Exception as e:
        return {"error": str(e)}

@app.get("/metas/{user_id}/progreso")
def progreso_meta(user_id: int):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Metas WHERE user=%s ORDER BY start_date DESC LIMIT 1", (user_id,))
        meta = cursor.fetchone()
        if not meta:
            return {"message": "No hay metas registradas para este usuario."}

        cursor.execute("SELECT chargeName, amount, category, utility FROM Gastos WHERE user=%s", (user_id,))
        gastos = cursor.fetchall()
        cursor.close()
        conn.close()

        if not gastos:
            return {"message": "No hay gastos registrados para este usuario."}

        total_gastado = sum(g['amount'] for g in gastos)
        total_regret = sum(g['amount'] for g in gastos if g['utility'] == 'regret')
        progreso_pct = min((total_gastado / meta['goal_amount']) * 100, 100)
        monto_restante = max(meta['goal_amount'] - total_gastado, 0)

        gastos_text = "\n".join([f"{g['chargeName']} - ${g['amount']} - {g['category']} - {g['utility']}" for g in gastos])
        prompt = (
            f"Analiza estos gastos de un usuario y genera tips de mejora financiera. "
            f"Indica qué gastos no deberían haberse hecho, en qué ha mejorado y consejos prácticos. "
            f"Devuélvelo en JSON con campos: 'regrets', 'improvements', 'tips'.\n\n"
            f"Gastos:\n{gastos_text}"
        )
        response = model.generate_content(prompt)
        feedback = response.text.strip()

        return {
            "meta": {
                "name": meta['name'],
                "description": meta['description'],
                "goal_amount": meta['goal_amount'],
                "start_date": str(meta['start_date']),
                "end_date": str(meta['end_date'])
            },
            "numerical_progress": {
                "total_spent": total_gastado,
                "total_regret": total_regret,
                "progress_percent": progreso_pct,
                "amount_remaining": monto_restante
            },
            "feedback": feedback
        }

    except Exception as e:
        return {"error": str(e)}

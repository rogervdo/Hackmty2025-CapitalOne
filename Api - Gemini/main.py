from fastapi import FastAPI, Body
import google.generativeai as genai
import mysql.connector
from datetime import datetime

# Configuración de Gemini AI
genai.configure(api_key="AIzaSyB9JIhKFx4cMnI55j2qGYGT1wFoUoeCGSw")
model = genai.GenerativeModel("gemini-2.0-flash")

# Configuración de la base de datos
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


# ------------------------------
# Endpoint de emojis
# ------------------------------
@app.post("/emojis")
def ask_gemini(prompt: str = Body(..., embed=True)):
    """
    Devuelve un emoji según el tipo de gasto.
    """
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
        return {
            "emoji": text.split('"emoji":')[1].split(",")[0].replace('"', "").strip(),
            "category": text.split('"category":')[1]
            .split("}")[0]
            .replace('"', "")
            .strip(),
        }
    except Exception as e:
        return {"error": str(e)}


# ------------------------------
# Endpoint para nuevo gasto
# ------------------------------
@app.post("/gastos/nuevo")
def nuevo_gasto(
    chargeName: str = Body(...),
    amount: float = Body(...),
    location: str = Body(...),
    category: str = Body(...),
    utility: str = Body(...),
    user: int = Body(...),
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


# ------------------------------
# Endpoint para obtener todos los gastos
# ------------------------------
@app.get("/gastos")
def obtener_gastos():
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


# ------------------------------
# Endpoint para obtener gastos de un usuario
# ------------------------------
@app.get("/gastos/{user_id}")
def obtener_gastos_usuario(user_id: int):
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


# ------------------------------
# Endpoint para obtener gastos de un usuario con utility NULL
# ------------------------------
@app.get("/gastos/{user_id}/utility-null")
def obtener_gastos_usuario_utility_null(user_id: int):
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
                G.user = %s AND G.utility IS "not assigned"
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


# ------------------------------
# Endpoint Coach Metrics
# ------------------------------
@app.get("/coach/{user_id}")
def coach_metrics(user_id: int):
    """
    Devuelve métricas para la vista Coach.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Obtener gastos del usuario
        cursor.execute("SELECT amount, utility FROM Gastos WHERE user=%s", (user_id,))
        gastos = cursor.fetchall()

        necesarios = sum(g["amount"] for g in gastos if g["utility"] == "aligned")
        innecesarios = sum(g["amount"] for g in gastos if g["utility"] == "regret")
        unsortedTransactions = sum(1 for g in gastos if g["utility"] == "not assigned")

        # Tomar meta semanal más reciente
        cursor.execute(
            "SELECT goal_amount, start_date, end_date FROM Metas WHERE user=%s ORDER BY start_date DESC LIMIT 1",
            (user_id,),
        )
        meta = cursor.fetchone()
        capSemanal = meta["goal_amount"] if meta else 1000
        metaSemanal = meta["goal_amount"] if meta else 1800

        progress = min(necesarios / metaSemanal, 1) if meta else 0.37
        impactoTotal = (
            innecesarios * 0.5
        )  # ejemplo: 50% del gasto innecesario se podría ahorrar

        cursor.close()
        conn.close()

        return {
            "necesarios": necesarios,
            "innecesarios": innecesarios,
            "capSemanal": capSemanal,
            "metaSemanal": metaSemanal,
            "progress": round(progress, 2),
            "unsortedTransactions": unsortedTransactions,
            "impactoTotal": impactoTotal,
        }
    except Exception as e:
        return {"error": str(e)}


# ------------------------------
# Endpoint Coach Opportunities
# ------------------------------
@app.get("/coach/{user_id}/opportunities")
def coach_opportunities(user_id: int):
    """
    Devuelve oportunidades de ahorro para la vista Coach.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT chargeName, amount, category FROM Gastos WHERE user=%s AND utility='regret'",
            (user_id,),
        )
        gastos_regret = cursor.fetchall()
        cursor.close()
        conn.close()

        opportunities = []
        for g in gastos_regret:
            opportunities.append(
                {
                    "title": f"Gasto innecesario: {g['chargeName']}",
                    "description": f"Este gasto de ${g['amount']} en {g['category']} podría haberse evitado.",
                    "primaryAction": "Revisar gasto",
                    "secondaryAction": "Establecer límite",
                }
            )

        return {"opportunities": opportunities[:3]}  # limitar a 3 oportunidades
    except Exception as e:
        return {"error": str(e)}

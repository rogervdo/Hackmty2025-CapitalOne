from fastapi import FastAPI, Body
from fastapi.middleware.cors import CORSMiddleware
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

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (for development)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)


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
    Devuelve métricas y el nombre de la última meta para la vista Coach.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 1. Obtener gastos del usuario y calcular métricas
        cursor.execute("SELECT amount, utility FROM Gastos WHERE user=%s", (user_id,))
        gastos = cursor.fetchall()

        necesarios = sum(g["amount"] for g in gastos if g["utility"] == "aligned")
        innecesarios = sum(g["amount"] for g in gastos if g["utility"] == "regret")
        unsortedTransactions = sum(1 for g in gastos if g["utility"] == "not assigned")

        # 2. Obtener solo el nombre y monto de la última meta (AQUÍ ESTÁ EL CAMBIO)
        cursor.execute(
            "SELECT nombre_meta, goal_amount FROM Metas WHERE user=%s ORDER BY start_date DESC LIMIT 1",
            (user_id,),
        )
        meta = cursor.fetchone()

        # 3. Asignar valores
        # Usamos el monto de la meta (goal_amount) o un valor por defecto
        metaSemanal = meta["goal_amount"] if meta and meta["goal_amount"] else 1800
        capSemanal = necesarios  # Mantener la lógica existente

        progress = min(necesarios / metaSemanal, 1) if metaSemanal > 0 else 0.37
        impactoTotal = innecesarios * 0.5

        # 4. Cerrar conexión
        cursor.close()
        conn.close()

        # 5. RETORNO FINAL (Solo incluye 'goalName')
        return {
            "necesarios": necesarios,
            "innecesarios": innecesarios,
            "capSemanal": capSemanal,
            "metaSemanal": metaSemanal,
            "progress": round(progress, 2),
            "unsortedTransactions": unsortedTransactions,
            "impactoTotal": impactoTotal,
            # CAMPO DE LA META
            "goalName": meta["nombre_meta"] if meta else "No goal set",
        }
    except Exception as e:
        # Asegúrate de cerrar la conexión en caso de error
        if "conn" in locals() and conn.is_connected():
            conn.close()
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


@app.post("/metas")
def crear_meta(
    prompt: str = Body(..., embed=True), user_id: int = Body(..., embed=True)
):
    """
    Crea una meta a partir de un prompt libre y la guarda en la base de datos.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Pedimos a Gemini que genere la meta en JSON estructurado
        base_prompt = f"""
        Eres un asesor financiero. A partir del siguiente prompt del usuario:
        "{prompt}"

        Genera un JSON con esta estructura:
        {{
          "nombre_meta": "...",
          "descripcion": "...",
          "monto_objetivo": <float>,
          "tipo": "ahorro" o "reducción de gasto",
          "fecha_inicio": "YYYY-MM-DD",
          "fecha_fin": "YYYY-MM-DD"
        }}
        """
        response = model.generate_content(base_prompt)
        meta_json = response.text.strip().replace("```json", "").replace("```", "")

        import json

        meta_data = json.loads(meta_json)

        # Guardamos la meta en la base de datos
        query = """
        INSERT INTO Metas (user, nombre_meta, descripcion, monto_objetivo, tipo, fecha_inicio, fecha_fin)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        values = (
            user_id,
            meta_data["nombre_meta"],
            meta_data["descripcion"],
            meta_data["monto_objetivo"],
            meta_data["tipo"],
            meta_data["fecha_inicio"],
            meta_data["fecha_fin"],
        )
        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return {"message": "✅ Meta creada exitosamente", "meta": meta_data}
    except Exception as e:
        return {"error": str(e)}


# ------------------------------
# Endpoint para obtener gastos no clasificados para SwipeView
# ------------------------------
@app.get("/swipe/unclassified/{user_id}")
def get_unclassified_transactions(user_id: int):
    """
    Devuelve un máximo de 10 gastos no clasificados (utility='not assigned')
    para el usuario especificado.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Consulta para obtener hasta 10 transacciones del usuario que no han sido clasificadas
        # Usamos G.id para que Swift tenga un ID único para la tarjeta
        query = """
            SELECT 
                G.id,
                G.chargeName, 
                G.amount, 
                G.timeStamp, 
                G.location,
                G.category,
                G.utility
            FROM 
                Gastos G
            WHERE 
                G.user = %s AND G.utility = 'not assigned'
            ORDER BY 
                G.timeStamp ASC
            LIMIT 10
        """
        cursor.execute(query, (user_id,))
        results = cursor.fetchall()

        cursor.close()
        conn.close()

        # Formatea el timeStamp para que sea compatible con Swift (opcional, pero ayuda)
        # y asegura que 'utility' se pase como el valor inicial 'not assigned'
        formatted_results = []
        for row in results:
            formatted_results.append(
                {
                    "id": row["id"],
                    "chargeName": row["chargeName"],
                    "amount": row["amount"],
                    "location": row["location"],
                    "category": row["category"],
                    "timestamp": row[
                        "timeStamp"
                    ].isoformat(),  # Convertir DATETIME a string ISO 8601
                    "utility": row["utility"],  # Debería ser 'not assigned'
                }
            )

        return {"transactions": formatted_results}

    except Exception as e:
        # Asegúrate de cerrar la conexión en caso de error
        if "conn" in locals() and conn.is_connected():
            conn.close()
        return {"error": str(e)}


# ------------------------------
# NUEVO Endpoint para actualizar la utilidad después del swipe
# ------------------------------
@app.post("/swipe/update")
def update_transaction_utility(
    transaction_id: int = Body(..., embed=True),
    utility_value: str = Body(..., embed=True),  # 'aligned' o 'regret'
):
    """
    Actualiza la columna 'utility' de un gasto después de que el usuario hace swipe.
    """
    if utility_value not in ["aligned", "regret"]:
        return {"error": "Invalid utility value. Must be 'aligned' or 'regret'."}

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            UPDATE Gastos
            SET utility = %s
            WHERE id = %s
        """
        values = (utility_value, transaction_id)
        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return {"message": "✅ Utility updated successfully."}

    except Exception as e:
        if "conn" in locals() and conn.is_connected():
            conn.close()
        return {"error": str(e)}


# ------------------------------
# Endpoint para resetear TODAS las utilidades a "not assigned"
# ------------------------------
@app.post("/gastos/reset-utilities")
def reset_all_utilities(confirm: bool = Body(True, embed=True)):
    """
    Actualiza TODAS las transacciones en la base de datos
    estableciendo utility = 'not assigned'.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            UPDATE Gastos
            SET utility = 'not assigned'
        """
        cursor.execute(query)
        affected_rows = cursor.rowcount
        conn.commit()

        cursor.close()
        conn.close()

        return {
            "message": "✅ All utilities have been reset to 'not assigned'.",
            "affected_rows": affected_rows,
        }

    except Exception as e:
        if "conn" in locals() and conn.is_connected():
            conn.close()
        return {"error": str(e)}

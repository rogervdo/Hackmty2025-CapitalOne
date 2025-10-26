# ✨ Cappie ✨ 
### “Pequeños cambios, grandes logros.”

---
### Problem Addressed
Managing money is time-consuming and mentally taxing. Most banking apps are **reactive** (balances + lists) and don’t guide the user with **clear, actionable steps**. Budgets are often rigid or vague, and they don’t show the **impact** of small daily choices on weekly goals.

### Our Solution: **Cappie**
A **Financial Coach** inside a banking app that turns transactions into **simple, explainable actions**.

**How the MVP (Normal mode) works:**
- **“Tinder for spending” onboarding:** quick swipes (✅ / ❌) to learn habits.
- **Emoji + map-based history:** fast, emotional visualization by category/location.
- **Weekly goals + Savings Envelope:** small, achievable targets and a ledger to “compensate now”.
- **Explainable recommendations (the “why”):** generated with **Gemini**, while metrics/rules run **on-device** for privacy.
- **Coach Metrics & Opportunities:** real-time metrics (needs, regrets, progress) and saving opportunities from “regret” expenses.
- **AI-assisted classification:** emoji/category suggestions and goal creation from a free-text prompt.

**Expected outcome (MVP):**
- Less friction to understand spending.
- **Small changes** that **accelerate goals** (“Pequeños cambios, grandes logros.”).
- A **friendly, non-punitive** experience aligned with Capital One’s spirit.

### Technologies Used
| Layer | Technologies | Purpose |
|---|---|---|
| **Frontend (iOS)** | **SwiftUI**, Combine, Swift Charts | Native UI: coach views, emoji history, goals & envelope. |
| **Backend (API)** | **FastAPI**, Uvicorn, Pydantic | REST endpoints: expenses, coach metrics, opportunities, swipe, goals, emojis. |
| **Database** | **MySQL 8** | Tables: `Usuario`, `Gastos`, `Metas`. Seed/Dump: `HackMTYCapitalOne2025.sql`. |
| **AI (NLG)** | **Google Gemini API** | Suggestions, emoji categorization, goal creation from prompt. |
| **Connector** | `mysql-connector-python` | MySQL access from FastAPI. |
| **Infra/Dev** | (Optional) Docker Compose | Local orchestration: API + DB. |
| **Design** | Figma (Capital One vibe) | Palette: Blue `#004481`, Red `#D10000`, Background `#F5F7FA`. |

**Key Endpoints (summary):**
`POST /gastos/nuevo`, `GET /gastos/{user_id}`, `GET /coach/{user_id}`,  
`GET /coach/{user_id}/opportunities`, `GET /swipe/unclassified/{user_id}`, `POST /swipe/update`,  
`POST /metas`, `POST /emojis`

> Interactive docs: `http://localhost:8000/docs`

---

## 🚀 Instalación rápida

> Requisitos: Python 3.10+, MySQL 8+

```bash
# 1) Instalar dependencias
pip install -r requirements.txt

# 2) Variables de entorno (crea .env y NO lo subas)
#   GEMINI_API_KEY=tu_api_key
#   MYSQL_HOST=localhost
#   MYSQL_PORT=3306
#   MYSQL_DB=CapitalOne
#   MYSQL_USER=cappie_user
#   MYSQL_PASSWORD=change_me

# 3) Cargar base de datos
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS CapitalOne;"
mysql -u root -p CapitalOne < backend/HackMTYCapitalOne2025.sql
# (Opcional) usuario app
mysql -u root -p -e "CREATE USER IF NOT EXISTS 'cappie_user'@'%' IDENTIFIED BY 'change_me'; GRANT ALL ON CapitalOne.* TO 'cappie_user'@'%'; FLUSH PRIVILEGES;"

# 4) Levantar API
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Docs:
# Swagger UI → http://localhost:8000/docs
# Redoc      → http://localhost:8000/redoc

## 👥 Equipo responsable

<div align="left">

<!-- Avatares (opcional) -->
<a href="https://github.com/tu-usuario">
  <img src="https://github.com/tu-usuario.png?size=100" width="64" height="64" style="border-radius:12px" alt="Tu Nombre" />
</a>
<a href="https://github.com/otro-usuario">
  <img src="https://github.com/otro-usuario.png?size=100" width="64" height="64" style="border-radius:12px" alt="Otro Nombre" />
</a>
<!-- Duplica el bloque <a> por cada integrante -->

</div>

| Rol | Nombre | GitHub | Contacto | Responsabilidades |
|---|---|---|---|---|
| Líder Backend | Pablo Zapata | [@tu-usuario](https://github.com/PabloZL27) | correo@ejemplo.com | API FastAPI, DB MySQL, endpoints y seguridad |
| iOS / SwiftUI | Nombre Integrante | [@otro-usuario](https://github.com/otro-usuario) | correo@ejemplo.com | Vistas SwiftUI, flujo Coach, sobre de ahorro |
| IA / NLG | Nombre Integrante | [@alguien](https://github.com/alguien) | correo@ejemplo.com | Prompts Gemini, explicación “por qué”, emojis |
| Diseño/UI | Nombre Integrante | [@alguien-mas](https://github.com/alguien-mas) | correo@ejemplo.com | Figma, paleta Capital One, componentes |
| QA / Demo | Nombre Integrante | [@qa-user](https://github.com/qa-user) | correo@ejemplo.com | Casos de prueba, datos seed, script de demo |


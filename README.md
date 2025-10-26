<div align="center">

<img src="https://dummyimage.com/1200x240/004481/ffffff&text=Cappie" alt="Cappie banner (placeholder)" width="100%" />

<h1>✨ Cappie ✨</h1>
<h3><i>“Pequeños cambios, grandes logros.”</i></h3>

<!-- Badges -->
<a href="#"><img alt="HackMTY" src="https://img.shields.io/badge/HackMTY-2025-004481"></a>
<a href="#"><img alt="Sponsor" src="https://img.shields.io/badge/Sponsor-Capital%20One-D10000"></a>
<a href="#"><img alt="FastAPI" src="https://img.shields.io/badge/API-FastAPI-009688"></a>
<a href="#"><img alt="MySQL" src="https://img.shields.io/badge/DB-MySQL%208-4479A1"></a>
<a href="#"><img alt="iOS" src="https://img.shields.io/badge/App-iOS%20SwiftUI-0A84FF"></a>
<a href="#"><img alt="Gemini" src="https://img.shields.io/badge/AI-Google%20Gemini-5E5DF0"></a>

<br/><br/>
</div>

> **Cappie** is a banking app with a **Financial Coach** (Normal mode) that turns your transactions into **simple, explainable actions** — inspired by Capital One’s friendly, trustworthy vibe.

---

## 🔎 Table of Contents
- [✨ Project Description](#-project-description)
- [🛠️ Technologies Used](#️-technologies-used)
- [🚀 Quick Start](#-quick-start)
- [🔌 API — Key Endpoints](#-api--key-endpoints)
- [🗄️ Database (MySQL) & Seed](#️-database-mysql--seed)
- [👥 Team](#-team)
- [🤝 Acknowledgements](#-acknowledgements)

---

## ✨ Project Description

### Problem Addressed
Managing money is time-consuming and mentally taxing. Most banking apps are **reactive** (balances + lists) and don’t guide the user with **clear, actionable steps**. Budgets can be rigid or vague, and they rarely show the **impact** of small daily choices on weekly goals.

### Our Solution: **Cappie**
A **Financial Coach** inside a banking app that turns transactions into **simple, explainable actions**.

**How the MVP (Normal mode) works**
- **“Tinder for spending” onboarding:** quick swipes (✅ / ❌) to learn habits.
- **Emoji + map-based history:** fast, emotional visualization by category/location.
- **Weekly goals + Savings Envelope:** small, achievable targets and a ledger to “compensate now”.
- **Explainable recommendations (the “why”):** generated with **Gemini**, while metrics/rules run **on-device** for privacy.
- **Coach Metrics & Opportunities:** real-time metrics (needs, regrets, progress), and saving opportunities from “regret” expenses.
- **AI-assisted classification:** emoji/category suggestions and goal creation from a free-text prompt.

**Expected outcome (MVP)**
- Less friction to understand spending.
- **Small changes** that **accelerate goals** (“Pequeños cambios, grandes logros.”).
- A **friendly, non-punitive** experience aligned with Capital One’s spirit.

---

## 🛠️ Technologies Used

| Layer | Technologies | Purpose |
|---|---|---|
| **Frontend (iOS)** | **SwiftUI**, Combine, Swift Charts | Native UI: coach views, emoji history, goals & envelope. |
| **Backend (API)** | **FastAPI**, Uvicorn, Pydantic | REST endpoints: expenses, coach metrics, opportunities, swipe, goals, emojis. |
| **Database** | **MySQL 8** | Tables: `Usuario`, `Gastos`, `Metas`. Seed/Dump: `backend/HackMTYCapitalOne2025.sql`. |
| **AI (NLG)** | **Google Gemini API** | Suggestions, emoji categorization, goal creation from prompt. |
| **Connector** | `mysql-connector-python` | MySQL access from FastAPI. |
| **Design** | Figma (Capital One vibe) | Palette: Blue `#004481`, Red `#D10000`, Background `#F5F7FA`. |

---

## 🚀 Quick Start

> Requirements: Python 3.10+, MySQL 8+

```bash
# 1) Install deps
pip install -r requirements.txt

# 2) Environment variables (create .env — do NOT commit)
#   GEMINI_API_KEY=your_key
#   MYSQL_HOST=localhost
#   MYSQL_PORT=3306
#   MYSQL_DB=CapitalOne
#   MYSQL_USER=cappie_user
#   MYSQL_PASSWORD=change_me

# 3) Load database (see section below if you need a new user)
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS CapitalOne;"
mysql -u root -p CapitalOne < backend/HackMTYCapitalOne2025.sql

# (Optional) App DB user
mysql -u root -p -e "CREATE USER IF NOT EXISTS 'cappie_user'@'%' IDENTIFIED BY 'change_me';
GRANT ALL ON CapitalOne.* TO 'cappie_user'@'%'; FLUSH PRIVILEGES;"

# 4) Run API
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Docs:
# Swagger UI → http://localhost:8000/docs
# Redoc      → http://localhost:8000/redoc
```

## 🔌 API — Key Endpoints

| Method | Route | Body / Params (summary) | Description |
|---|---|---|---|
| **POST** | `/emojis` | `{ "prompt": "text" }` | Returns **emoji** and **category** for an expense using Gemini. |
| **POST** | `/gastos/nuevo` | `{ chargeName, amount, location, category, utility, user }` | Creates a new **expense**. |
| **GET** | `/gastos` | — | Lists all expenses joined with user name. |
| **GET** | `/gastos/{user_id}` | `user_id` path | Lists a user’s expenses (newest first). |
| **GET** | `/gastos/{user_id}/utility-null` | `user_id` path | Lists a user’s **unclassified** expenses (`utility = 'not assigned'`). |
| **GET** | `/coach/{user_id}` | `user_id` path | Coach metrics: **needs**, **regrets**, **weekly cap**, **goal**, **progress**, **unsorted count**, **impact**. |
| **GET** | `/coach/{user_id}/opportunities` | `user_id` path | Saving opportunities derived from **regret** expenses (top 3). |
| **GET** | `/swipe/unclassified/{user_id}` | `user_id` path | Up to **10** unclassified transactions for the **Swipe** view. |
| **POST** | `/swipe/update` | `{ "transaction_id": n, "utility_value": "aligned"|"regret" }` | Updates `utility` after swipe. |
| **POST** | `/metas` | `{ "prompt": "...", "user_id": n }` | Creates a **goal** from free-text using Gemini and saves it. |

> Interactive docs: **`/docs`** (Swagger) · **`/redoc`**  
> Note: In SQL for *utility-null* use `utility = 'not assigned'` (not `IS`).


---

## 📘 Database (MySQL) & Seed

**Schema (main tables)**

| Table | Key Fields | Notes |
|---|---|---|
| `Usuario` | `idUser`, `user`, `password` | Demo users included in seed. |
| `Gastos` | `id`, `chargeName`, `amount`, `timeStamp`, `location`, `category`, `utility`, `user` | `utility ∈ {'aligned','regret','not assigned'}` |
| `Metas` | `idMeta`, `user`, `nombre_meta`, `descripcion`, `goal_amount`, `tipo`, `start_date`, `end_date` | Linked to users; **column names matter**. |

**Load seed**
```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS CapitalOne;"
mysql -u root -p CapitalOne < backend/HackMTYCapitalOne2025.sql

# Optional: dedicated app user
mysql -u root -p -e "CREATE USER IF NOT EXISTS 'cappie_user'@'%' IDENTIFIED BY 'change_me';
GRANT ALL ON CapitalOne.* TO 'cappie_user'@'%'; FLUSH PRIVILEGES;"
```

## 👥 Team

<div align="left">

<a href="https://github.com/zamer22">
  <img src="https://github.com/zamer22.png?size=100" width="64" height="64" style="border-radius:12px" alt="Angel Muñoz" />
</a>
<a href="https://github.com/rogervdo">
  <img src="https://github.com/rogervdo.png?size=100" width="64" height="64" style="border-radius:12px" alt="Rogelio Villareal" />
</a>
<a href="https://github.com/Bryan-Meza">
  <img src="https://github.com/Bryan-Meza.png?size=100" width="64" height="64" style="border-radius:12px" alt="Bryan Meza" />
</a>
<a href="https://github.com/PabloZL27">
  <img src="https://github.com/PabloZL27.png?size=100" width="64" height="64" style="border-radius:12px" alt="Pablo Zapata" />
</a>

</div>

| Role | Name | GitHub | Contact | 
|---|---|---|---|---|
| Backend Lead | Angel Muñoz | [@zamer22](https://github.com/PabloZL27) | <angelaamunoza@gmail.com> | 
| Backend Lead | Rogelio Villareal | [@rogervdo](https://github.com/user) | <rogervdo@icloud.com> | 
| Design / UI / SwiftUI | Bryan Meza | [@Bryan-Meza](https://github.com/user) | <bryan.albertolemus9@gmail.com> | 
| Design / UI / SwiftUI | Pablo Zapata | [@PabloZL27](https://github.com/user) | <Pablo.ZZLL@hotmail.com> | 

---

## 💛 Acknowledgements

- **Capital One** — inspiration and sponsorship.  
- **HackMTY 2025** — venue to build Cappie.  
- Mentors & community who provided feedback and testing.


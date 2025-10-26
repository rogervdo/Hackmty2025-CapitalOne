# 💳 Cappie  
### “Pequeños cambios, grandes logros.”

---
### Problem Addressed
Managing money is time-consuming and mentally taxing. Most banking apps are **reactive** (balances + lists) and don’t guide the user with **clear, actionable steps**. Budgets are often rigid or vague, and they don’t show the **impact** of small daily choices on weekly goals.

### Our Solution: **Cappie**
A **Financial Coach** inside a banking app that turns transactions into **simple, explainable actions**.

**How the MVP (Normal mode) works:**
- **“Tinder for spending” onboarding:** quick swipes (👍 / 👎) to learn habits.
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
# 💳 Cappie  
### “Pequechos cambios, grandes logros.”

---

## 🧠 Descripción general  
**Cappie** es una aplicación bancaria con un **Coach Financiero impulsado por IA**, inspirada en el estilo y filosofía de **Capital One**.  
Su objetivo es ayudar a los usuarios a **mejorar sus hábitos financieros** mediante pequeños cambios diarios que se traducen en **grandes logros** a lo largo del tiempo.  

En su versión **MVP**, Cappie se centra en el **modo Normal**, donde el usuario recibe recomendaciones inteligentes y personalizadas sin presión, basadas en su comportamiento financiero y metas semanales.  

---

## 💡 Características principales  
- 💬 **Coach Financiero AI (Modo Normal):**  
  Sugiere acciones personalizadas según tus gastos, ingresos y metas.  
- 💸 **Onboarding tipo “Tinder de gastos”:**  
  Clasifica hábitos con gestos simples (me gusta / no me gusta).  
- 📊 **Historial con emojis y mapa interactivo:**  
  Visualiza transacciones de forma divertida y emocional.  
- 🎯 **Metas semanales y sobre de ahorro:**  
  Fija metas realistas y compensa desviaciones con el “Sobre de Ahorro”.  
- 🤖 **Gemini + on-device calculations:**  
  El coach usa **Gemini** (para lenguaje y explicaciones) y el cálculo de métricas se hace **en el dispositivo**, protegiendo la privacidad del usuario.  
- 🏦 **Ecosistema bancario completo:**  
  Pantallas de **login, cuentas, movimientos, pagos y perfil** integradas.

---

## 🧩 Arquitectura del proyecto  
| Capa | Descripción | Stack |
|------|--------------|-------|
| **Frontend (App iOS)** | Interfaz principal con vistas SwiftUI y componentes nativos. | `SwiftUI`, `Combine`, `Swift Charts` |
| **Backend (Simulado)** | API mock de banca y transacciones. | `Node.js / Express` o `FastAPI` (según demo) |
| **Coach AI** | Motor NLG para sugerencias y explicaciones. | `Google Gemini API` |
| **On-device Engine** | Cálculo de métricas, límites y simulaciones. | `Swift` (local compute) |
| **Diseño UI/UX** | Inspirado en Capital One: azul #004481, rojo #D10000, blanco #F5F7FA. | `Figma`, `SF Symbols` |

---

## 🚀 Instalación y ejecución  
1. Clona el repositorio:  
   ```bash
   git clone https://github.com/<tu-usuario>/Cappie.git
   cd Cappie

# ✨ Aura Mart — *Elevate Your Shopping Experience* ✨

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

Aura Mart is a **premium digital storefront** designed with elegance, speed, and high performance in mind. Built using **Flutter** and **Firebase**, it delivers a seamless end-to-end shopping journey from product discovery to secure order tracking.

---

## 💎 Premium Features

*   **⚡ Intelligent Onboarding:** Animated splash screen that manages user sessions and auto-routes to Home or Login.
*   **🛡️ Secure Auth Core:** Bulletproof Login & Registration with real-time profile syncing and a dedicated Password Recovery portal.
*   **🎨 Next-Gen UI:** Features a unique **Floating "Bubble" Navigation Bar** and a sleek, modern design language.
*   **🔍 Smart Discovery:** Real-time search engine and category filtering that updates your storefront instantly.
*   **❤️ Persistent Cloud Wishlist:** Save your favorite items to the cloud; they stay with you even after logging out (powered by Firestore).
*   **🛒 Advanced Cart & Checkout:** Full quantity management, swipe-to-delete, and a simulated payment gateway.
*   **📦 Real-time Order Tracking:** View your entire purchase history with detailed, collapsible order cards.
*   **🌙 Dynamic Themes:** Luxurious Deep Purple palette with full support for System Light/Dark modes.

---

## 🛣️ The Journey (Workflow)

### 🟢 Phase 1: The Entrance
*   **Immersive Splash:** A high-fidelity animation that checks for an active Firebase session.
*   **Identity Guard:** Automatically welcomes known users or guides guests to the secure Auth Portal.

### 🔵 Phase 2: Discovery
*   **Bento Dashboard:** Browse trending products with high-quality imagery and live search.
*   **Category Explorer:** Specialized screens for Electronics, Fashion, Home, and more, using a highly scalable architectural template.

### 🟣 Phase 3: Selection & Purchase
*   **Wishlist Sync:** Items liked on the dashboard appear instantly in your private Wishlist screen.
*   **The Boutique (Cart):** Manage your selections, see real-time price totals, and proceed through a multi-step simulated payment gateway.

### 🟡 Phase 4: Order Management
*   **Persona (Profile):** Full account control and a dedicated "My Orders" screen to track every purchase made on Aura Mart.

---

## 🛠️ Technical Blueprint

| Layer | Technology |
| :--- | :--- |
| **Frontend** | Flutter (Material 3) |
| **Backend/Database** | Firebase Cloud Firestore |
| **Authentication** | Firebase Auth |
| **State Management** | Real-time Streams & StatefulWidget |
| **Logic Layer** | Centralized Service Architecture (Auth, Cart, Wishlist, Order) |

---

## 📦 Installation & Setup

1.  **Clone the Vision**
    ```bash
    git clone https://github.com/your-username/aura_mart.git
    ```
2.  **Pull the Assets**
    ```bash
    flutter pub get
    ```
3.  **Bridge to Firebase**
    - Place your `google-services.json` in `android/app/`.
    - Ensure **Firestore** and **Auth** (Email/Password) are enabled in your Firebase console.
4.  **Launch**
    ```bash
    flutter run
    ```

---

## 🤝 Contribution
Designed with ❤️ for the Flutter community. Feel free to fork, star, and contribute to the Aura Mart evolution!

---
*Developed by [Anshu Kumar](https://github.com/anshu-ac-dv)*

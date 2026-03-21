# ✨ Aura Mart — *Elevate Your Shopping Experience* ✨

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

Aura Mart is a **premium digital storefront** designed with elegance, speed, and high performance in mind. Built using **Flutter** and **Firebase**, it delivers a seamless end-to-end shopping journey from intelligent onboarding to secure order tracking.

---

## 💎 Latest Premium Features

*   **⚡ Intelligent Onboarding:** Animated splash screen that manages user sessions and auto-routes to Home or Login portals.
*   **🛡️ Secure Auth Core:** Bulletproof Login & Registration with real-time profile syncing and a dedicated Password Recovery system.
*   **🎨 Next-Gen UI:** Features a unique **Floating "Bubble" Navigation Bar** and a sleek, modern design language inspired by industry leaders.
*   **🔍 Smart Discovery:** Real-time search engine and 3-column circular category filtering that updates your storefront instantly.
*   **❤️ Cloud-Synced Wishlist:** Save your favorite items to the cloud; they stay with you even after logging out (powered by real-time Firestore streams).
*   **🛒 Advanced Cart System:** Full quantity management, swipe-to-delete, and real-time subtotal calculations.
*   **💳 Secure Checkout Flow:** Simulated multi-step payment gateway with a celebratory "Order Success" animation.
*   **📍 Address Management:** Save multiple shipping addresses (Home/Work) with default address selection logic.
*   **📦 Real-time Order Tracking:** View your entire purchase history with detailed, collapsible order cards showing status and timestamps.
*   **🌙 Dynamic Themes:** Luxurious Deep Purple palette with optimized support for System Light and Dark modes.

---

## 🛣️ The Journey (Workflow)

### 🟢 Phase 1: The Entrance
*   **Immersive Splash:** A high-fidelity animation that silently validates the active Firebase session.
*   **Identity Guard:** Welcomes known users directly or guides guests to the secure Auth Portal.

### 🔵 Phase 2: Discovery (Amazon/Flipkart Style)
*   **Branded Dashboard:** Featuring a premium top branding bar, delivery location selector, and deals slider.
*   **Grid Explorer:** Browse products through specialized horizontal deals or a dense, high-conversion product grid.

### 🟣 Phase 3: Selection & Purchase
*   **Sync Logic:** Real-time heart icons on the dashboard sync instantly with your private Wishlist screen.
*   **The Boutique (Cart):** Manage selections and proceed through a professional payment selection bottom sheet.

### 🟡 Phase 4: Account & History
*   **Persona (Profile):** Full account control including address management and a dedicated "My Orders" screen.

---

## 🛠️ Technical Blueprint

| Layer | Technology |
| :--- | :--- |
| **Frontend** | Flutter (Material 3) |
| **Database** | Firebase Cloud Firestore |
| **Authentication** | Firebase Auth (Email/Pass) |
| **State Management** | Real-time Streams & StatefulWidget |
| **Logic Layer** | Centralized Service Architecture (Auth, Cart, Wishlist, Order, Address) |
| **Storage** | Firebase Cloud Storage (Images) |

---

## 📂 Folder Structure (Clean Architecture)
```text
lib/
├── Core/           # Themes, Utils, Constants
├── Screens/        # UI Layer (Auth, Products, Tabs, Splash, Orders)
├── Services/       # Business Logic (Firebase integrations)
└── main.dart       # Entry point
```

---

## 📦 Installation & Setup

1.  **Clone the Vision**
    ```bash
    git clone https://github.com/anshu-ac-dv/aura_mart.git
    ```
2.  **Pull the Assets**
    ```bash
    flutter pub get
    ```
3.  **Bridge to Firebase**
    - Place your `google-services.json` in `android/app/`.
    - Enable **Firestore** and **Auth** in your Firebase console.
4.  **Launch**
    ```bash
    flutter run
    ```

---

## 🤝 Contribution
Designed with ❤️ for the Flutter community. Feel free to fork, star, and contribute to the Aura Mart evolution!

---
*Developed by [Anshu Kumar](https://github.com/anshu-ac-dv)*

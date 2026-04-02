# ✨ Aura Mart — *The Future of Premium Shopping* ✨

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**Aura Mart** is a high-performance, premium e-commerce application crafted with **Flutter** and powered by **Firebase**. It offers a seamless, secure, and visually stunning shopping experience designed for the modern user.

[Explore the Flow](#-visual-flow) • [Key Features](#-premium-features) • [Workflow](#-the-journey) • [Installation](#-installation--setup)

</div>

---

## 📸 Visual Flow

```mermaid
graph TD
    Start[🚀 App Launch] --> Splash[✨ Splash Screen]
    Splash -->|Auto Session Check| Auth{👤 Auth Status}
    
    Auth -->|Not Logged In| Login[🔐 Login Portal]
    Login -->|New User?| Register[📝 Create Account]
    Register -->|Success| Home[🏠 Home Dashboard]
    Login -->|Success| Home
    
    Auth -->|Logged In| Home
    
    Home -->|Explore| Categories[📂 Category Hub]
    Home -->|Search| Search[🔍 Smart Search]
    
    Categories --> Products[🛍️ Product Grid]
    Search --> Products
    
    Products -->|Add| Cart[🛒 Boutique Cart]
    Products -->|Like| Wishlist[❤️ Cloud Sync Wishlist]
    
    Cart -->|Checkout| Pay[💳 Multi-Step Payment]
    Pay -->|Success| Success[🎉 Order Success Animation]
    Success -->|Track| Orders[📦 Purchase History]
```

---

## 💎 Premium Features

| Feature | Description |
| :--- | :--- |
| **⚡ Intelligent Onboarding** | High-fidelity animated splash with real-time session validation. |
| **🛡️ Secure Auth Core** | Firebase-powered Login, Registration, and Password Recovery. |
| **🎨 Next-Gen UI** | Unique **Floating Bubble Navigation** and Amazon/Flipkart style aesthetics. |
| **🔍 Smart Discovery** | Real-time search engine with 3-column circular category filtering. |
| **❤️ Cloud Wishlist** | Persistent favorites that stay synced across all your devices. |
| **🛒 Advanced Cart** | Live quantity management, swipe-to-delete, and real-time subtotal tracking. |
| **💳 Secure Checkout** | Multi-step payment selection with celebratory order success animations. |
| **📍 Address Hub** | Manage multiple shipping profiles (Home/Office) with default settings. |
| **📦 Order Tracking** | Detailed history with collapsible status cards and server timestamps. |
| **🌙 Dynamic Themes** | Deep Purple branding with professional Light and Dark mode optimization. |

---

## 🛣️ The Journey (Workflow)

### 🟢 Phase 1: The Identity Portal
<img src="https://images.unsplash.com/photo-1534452286302-2f5630b0600d?q=80&w=1000&auto=format&fit=crop" width="350" align="right" style="border-radius: 20px; margin-left: 20px;" />

*   **Premium Entrance:** An immersive 4-second animation that welcomes users while the "Identity Guard" checks for an active session.
*   **Security First:** Distraction-free authentication forms with real-time validation and profile synchronization.

<br clear="right"/>

### 🔵 Phase 2: Product Discovery
<img src="https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1000&auto=format&fit=crop" width="350" align="left" style="border-radius: 20px; margin-right: 20px;" />

*   **Modern Hub:** A feature-rich dashboard with top branding, delivery location tracking, and interactive deal sliders.
*   **Scalable Architecture:** Dedicated screens for every category (Electronics, Fashion, Home) built on a unified architectural template.

<br clear="left"/>

### 🟣 Phase 3: Selection & Transaction
<img src="https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=1000&auto=format&fit=crop" width="350" align="right" style="border-radius: 20px; margin-left: 20px;" />

*   **Real-time Sync:** Liked items move to your cloud wishlist instantly using Firestore Streams.
*   **Smart Cart:** Dynamic quantity controls and a professional payment gateway simulation with immediate visual confirmation.

<br clear="right"/>

### 🟡 Phase 4: Order Lifecycle
<img src="https://images.unsplash.com/photo-1531403009284-440f080d1e12?q=80&w=1000&auto=format&fit=crop" width="350" align="left" style="border-radius: 20px; margin-right: 20px;" />

*   **Purchase History:** Every order is stored in the cloud with itemized details and real-time status updates.
*   **Account Control:** Easily manage addresses and profile settings through an intuitive "Persona" tab.

<br clear="left"/>

---

## 🛠️ Technical Blueprint

*   **Frontend Framework:** Flutter 3.x (Material 3)
*   **Backend Services:** Firebase (Auth, Firestore, Storage)
*   **State Management:** Real-time Streams & StatefulWidget
*   **Logic Layer:** Centralized Service Architecture
*   **Architecture Pattern:** Clean UI/Service separation

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
Designed with ❤️ for the global Flutter community. Feel free to fork, star, and contribute!

---
<div align="center">
    <b>Developed by [Anshu Kumar](https://github.com/anshu-ac-dv)</b>
</div>

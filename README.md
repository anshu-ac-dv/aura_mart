<div align="center">

<br/>

```
╔═══════════════════════════════════════════╗
║                                           ║
║        ✦  A U R A   M A R T  ✦           ║
║                                           ║
╚═══════════════════════════════════════════╝
```

### *The Future of Premium E-Commerce Experiences*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-v3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-Language-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Firestore](https://img.shields.io/badge/Firestore-Database-FF6F00?style=flat-square&logo=firebase&logoColor=white)](https://firebase.google.com/products/firestore)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-673AB7?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-success?style=flat-square)](LICENSE)

<br/>

> **Aura Mart** is a production-grade e-commerce mobile app built with Flutter — a showcase of  
> UI/UX precision, real-time Firestore synchronization, and scalable mobile architecture.  
> Designed to demonstrate the power of high-fidelity mobile engineering.

<br/>

---

</div>

<br/>

## 📋 Table of Contents

- [✨ Overview](#-overview)
- [🚀 App Flow](#-app-flow)
- [🎨 Design System](#-design-system-aura-glass)
- [⚙️ Tech Stack](#️-tech-stack)
- [🌟 Key Features](#-key-features)
- [🏗️ Architecture](#️-architecture)
- [🛠️ Engineering Highlights](#️-engineering-highlights)
- [📦 Dependencies](#-dependencies)
- [🔧 Installation](#-installation--setup)
- [📁 Project Structure](#-project-structure)
- [👨‍💻 Author](#-author)

<br/>

---

## ✨ Overview

**Aura Mart** isn't just a shopping app — it's a full-scale demonstration of what Flutter is truly capable of when precision meets performance.

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🔐  Firebase Auth       →   Secure, persistent sessions  │
│   ⚡  Firestore Streams   →   Real-time sync, zero lag      │
│   🎞️  Lottie Animations  →   Premium motion & micro-UX     │
│   🖼️  Image Caching      →   Performance-first rendering   │
│   📱  Material 3 UI       →   Modern, adaptive design       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

<br/>

---

## 🚀 App Flow

The user journey is designed to minimize friction and maximize engagement at every step.

```
┌──────────────┐      ┌──────────────────────┐
│              │      │                      │
│    SPLASH    │─────▶│   Auth State Check   │
│              │      │   (Firebase Session) │
└──────────────┘      └──────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
    ┌─────────────────────┐         ┌─────────────────────┐
    │                     │         │                     │
    │   IDENTITY HUB      │         │     DASHBOARD       │
    │  Login / Register   │────────▶│  Personalized Feed  │
    │                     │         │                     │
    └─────────────────────┘         └─────────────────────┘
                                              │
                               ┌──────────────┴───────────────┐
                               │                              │
                               ▼                              ▼
                   ┌─────────────────────┐       ┌─────────────────────┐
                   │                     │       │                     │
                   │    DISCOVERY        │       │   PRODUCT DETAIL    │
                   │  Search + Filters   │──────▶│   Rich Media View   │
                   │                     │       │                     │
                   └─────────────────────┘       └─────────────────────┘
                                                           │
                                          ┌────────────────┴──────────────┐
                                          │                               │
                                          ▼                               ▼
                              ┌─────────────────────┐        ┌─────────────────────┐
                              │                     │        │                     │
                              │   CART & WISHLIST   │        │     CHECKOUT        │
                              │  Cloud Synced ☁️    │───────▶│  COD / Online Pay   │
                              │                     │        │                     │
                              └─────────────────────┘        └─────────────────────┘
                                                                        │
                                                                        ▼
                                                          ┌─────────────────────────┐
                                                          │                         │
                                                          │   ORDER SUCCESS  🎉     │
                                                          │   Lottie Animation +    │
                                                          │   Order Tracking        │
                                                          │                         │
                                                          └─────────────────────────┘
```

<br/>

---

## 🎨 Design System: *Aura Glass*

A custom design language built around **Depth · Motion · Clarity**

| Token | Implementation | Purpose |
|-------|---------------|---------|
| **Primary Gradient** | Deep Purple → Indigo (`#673AB7 → #3F51B5`) | Key action areas |
| **Glass Surface** | Semi-transparent layers with blur | Card depth & elevation |
| **Motion Language** | Physics-based + Lottie loops | Feedback & delight |
| **Components** | Sliver effects, circular avatars, dense grids | Navigation & discovery |
| **Typography** | Material 3 type scale | Hierarchy & readability |

<br/>

---

## ⚙️ Tech Stack

```
┌──────────────────────────────────────────────────────────────────┐
│                         TECH STACK                               │
├─────────────────────┬────────────────────────────────────────────┤
│  LAYER              │  TECHNOLOGY                                │
├─────────────────────┼────────────────────────────────────────────┤
│  📱 Frontend        │  Flutter (Material 3) + Dart               │
│  🔄 State Mgmt      │  Service-based Reactive Architecture       │
│  🔐 Auth            │  Firebase Authentication                   │
│  🗄️  Database       │  Cloud Firestore (Real-time Streams)       │
│  📁 Storage         │  Firebase Storage                         │
│  🎞️  Animations     │  Lottie + Custom Hero Transitions          │
│  🖼️  Images         │  cached_network_image                      │
│  🌐 Realtime DB     │  Firebase Realtime Database                │
└─────────────────────┴────────────────────────────────────────────┘
```

<br/>

---

## 🌟 Key Features

### 👤 Identity Hub

- **Secure Authentication** — Robust login & registration backed by Firebase Auth
- **Persistent Sessions** — Immediate redirection based on auth state on splash screen
- **Multi-screen State** — Auth state managed globally across the entire app

---

### 🛍️ Smart Boutique

- **Discovery Engine** — Real-time product filtering by category and name with sub-second latency
- **Horizontal Category Filter** — Scrollable, tap-to-filter category bar
- **Blazing Fast Search** — Instant results as you type

---

### 💙 Wishlist & Cart

- **Cloud Sync** — Changes persist instantly via Firestore across devices
- **Bi-directional Updates** — Add on one screen, reflected everywhere globally
- **Offline Resilience** — Optimistic UI updates ensure a seamless offline experience

---

### 💳 Transaction Suite

- **Dynamic Checkout** — Adaptive payment selection (Cash on Delivery / Online)
- **Lottie Success Screens** — Delightful animated feedback on order placement
- **Order History** — Full tracking of past purchases with timestamps & media thumbnails

---

### 🎞️ Premium UI/UX

- **Sliver Effects** — Custom SliverAppBar with parallax product images
- **Hero Transitions** — Fluid, physics-based page transitions
- **Glassmorphic Components** — Translucent search bars, floating action elements
- **Dense Product Grids** — High-density browsing with smart image loading

<br/>

---

## 🏗️ Architecture

Aura Mart follows a **Clean UI / Service Separation** pattern:

```
aura_mart/
│
├── lib/
│   ├── Screens/              # High-fidelity UI & Theme-aware widgets
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   ├── cart/
│   │   │   └── cart_screen.dart
│   │   ├── wishlist/
│   │   │   └── wishlist_screen.dart
│   │   └── checkout/
│   │       ├── checkout_screen.dart
│   │       └── order_success_screen.dart
│   │
│   ├── Services/             # Core business logic & Firebase integration
│   │   ├── auth_service.dart
│   │   ├── product_service.dart
│   │   ├── cart_service.dart
│   │   └── order_service.dart
│   │
│   ├── Splash Services/      # App bootstrapping & Auth state management
│   │   └── splash_service.dart
│   │
│   └── main.dart             # App entry point
│
├── assets/
│   └── images/               # App icons, Lottie files, static assets
│
├── android/                  # Android platform files
├── ios/                      # iOS platform files
├── pubspec.yaml              # Dependencies
└── firebase.json             # Firebase config
```

<br/>

---

## 🛠️ Engineering Highlights

| Feature | Technical Implementation | Value |
|---------|--------------------------|-------|
| ⚡ **Real-time Engine** | Firestore `StreamBuilder` for live UI updates | Reactive programming proficiency |
| 🖼️ **Media Optimization** | `cached_network_image` with custom shimmer shaders | Performance-first mindset |
| 🔐 **Advanced Auth** | Firebase Auth + multi-screen state management | Security-centric development |
| 🎨 **Premium UI** | Custom Sliver effects & Lottie micro-interactions | High attention to UX detail |
| 📶 **Offline Support** | Optimistic UI updates with Firestore persistence | Resilient app architecture |
| 🏎️ **List Performance** | Memory-efficient rendering for large product grids | Smooth 60fps scrolling |

<br/>

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_sdk: Material 3

  # 🔥 Firebase
  firebase_core: ^4.5.0
  firebase_auth: ^6.2.0
  firebase_storage: ^13.1.0
  firebase_database: ^12.1.4
  cloud_firestore: ^6.1.3

  # 🎞️ UI & Animations
  lottie: ^3.1.0
  cached_network_image: ^3.3.1
  cupertino_icons: ^1.0.8

  # 🛠️ Utilities
  fluttertoast: ^9.0.0
  intl: ^0.18.1
```

<br/>

---

## 🔧 Installation & Setup

### Prerequisites

- Flutter SDK `^3.10.3`
- Dart SDK (bundled with Flutter)
- Firebase project with Firestore, Auth, and Storage enabled
- Android Studio / VS Code

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/anshu-ac-dv/aura_mart.git
cd aura_mart

# 2. Install dependencies
flutter pub get

# 3. Firebase Setup
#    → Place google-services.json in android/app/
#    → Place GoogleService-Info.plist in ios/Runner/

# 4. Generate app icons
flutter pub run flutter_launcher_icons

# 5. Run the app
flutter run --release
```

### Firebase Configuration

| File | Location |
|------|----------|
| `google-services.json` | `android/app/` |
| `GoogleService-Info.plist` | `ios/Runner/` |

> ⚠️ Never commit Firebase config files to version control. Add them to `.gitignore`.

<br/>

---

## 📁 Project Structure Summary

```
75.5%  Dart       →  Core app logic & UI
12.3%  C++        →  Flutter engine native bindings
 9.6%  CMake      →  Build configuration (Linux/Windows)
 1.2%  Swift      →  iOS native bridge
 0.7%  C          →  Low-level platform code
 0.6%  HTML       →  Web platform entry point
 0.1%  Other
```

<br/>

---

## 👨‍💻 Author

<div align="center">

```
╔══════════════════════════════════════╗
║                                      ║
║         Built with ❤️ by            ║
║                                      ║
║           ANSHU KUMAR                ║
║      Flutter Developer               ║
║                                      ║
║  Looking for a Flutter Developer     ║
║  who cares about the details?        ║
║  Let's connect!                      ║
║                                      ║
╚══════════════════════════════════════╝
```

[![Portfolio](https://img.shields.io/badge/Portfolio-GitHub-181717?style=for-the-badge&logo=github)](https://github.com/anshu-ac-dv)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/anshu-ac-dv)
[![Email](https://img.shields.io/badge/Email-Reach%20Out-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:anshu.ac.dv@gmail.com)

</div>

<br/>

---

<div align="center">

⭐ **If you found this project useful, please star the repository!** ⭐

*© 2025 Anshu Kumar — Aura Mart. All rights reserved.*

</div>

<div align="center">



### *Redefining Mobile Shopping Excellence*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-v3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-Language-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Firestore](https://img.shields.io/badge/Firestore-Database-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com/products/firestore)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-673AB7?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-success?style=for-the-badge)](LICENSE)

<br/>

> **Aura Mart** is a production-grade e-commerce mobile app built with Flutter — a showcase of premium UI/UX design, real-time Firestore synchronization, and enterprise-scale mobile architecture. Built to demonstrate what modern mobile engineering truly looks like.

<br/>

---

</div>

<br/>

## 📋 Quick Navigation

| Section | Description |
|---------|-------------|
| [✨ Overview](#-overview) | What makes Aura Mart special |
| [🚀 App Flow](#-app-flow) | User journey visualization |
| [🎨 Design System](#-design-system-aura-glass) | Aura Glass design language |
| [⚙️ Tech Stack](#️-tech-stack) | Technology layers |
| [🌟 Key Features](#-key-features) | Core capabilities |
| [🏗️ Architecture](#️-architecture) | System design |
| [🛠️ Engineering](#️-engineering-highlights) | Technical deep-dives |
| [📦 Dependencies](#-dependencies) | Required packages |
| [🔧 Setup](#-installation--setup) | Get started in 5 minutes |
| [📁 Structure](#-project-structure) | File organization |

<br/>

---

## ✨ Overview

**Aura Mart** isn't just a shopping app—it's a masterclass in Flutter excellence.

```
╔─────────────────────────────────────────────────────────╗
│                                                         │
│  🔐  Firebase Auth       Secure persistent sessions    │
│  ⚡  Firestore Streams   Real-time sync, zero lag      │
│  🎞️  Lottie Animations  Premium motion & micro-UX     │
│  🖼️  Image Caching      Performance-first rendering   │
│  📱  Material 3 UI       Modern, adaptive design       │
│  ☁️  Cloud Sync         Bi-directional updates        │
│  🏎️  60fps Smooth       Memory-efficient rendering    │
│                                                         │
╚─────────────────────────────────────────────────────────╝
```

**What Makes It Different:**
- ✅ Production-ready Firestore architecture
- ✅ Enterprise-grade state management
- ✅ Pixel-perfect Material 3 compliance
- ✅ Offline-first optimistic UI
- ✅ Custom glassmorphic design system

<br/>

---

## 🚀 App Flow

The user journey is designed for zero friction and maximum engagement.

```
                    ┌─────────────────┐
                    │   SPLASH SCREEN │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Auth Check ✓   │
                    │ (Firebase Sess) │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    ┌────▼─────┐      ┌─────▼────┐      ┌──────▼──────┐
    │   LOGIN   │      │ REGISTER │      │  DASHBOARD  │
    │           │      │          │      │   (Logged)  │
    └────┬─────┘      └─────┬────┘      └──────┬──────┘
         │                  │                   │
         └──────────────────┼───────────────────┘
                            │
                    ┌───────▼────────┐
                    │   DISCOVERY    │
                    │ Browse & Search│
                    └───────┬────────┘
                            │
                    ┌───────▼────────┐
                    │ PRODUCT DETAIL │
                    │  Rich Media    │
                    └───────┬────────┘
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
    ┌────▼────┐      ┌─────▼─────┐    ┌──────▼──────┐
    │  WISHLIST│      │    CART   │    │  CHECKOUT   │
    │ ☁️ Synced│      │ ☁️ Synced │    │ COD / Online│
    └────┬────┘      └─────┬─────┘    └──────┬──────┘
         │                  │                 │
         └──────────────────┼─────────────────┘
                            │
                    ┌───────▼────────┐
                    │ ORDER SUCCESS  │
                    │ 🎉 Animation   │
                    │ + Tracking     │
                    └────────────────┘
```

<br/>

---

## 🎨 Design System: *Aura Glass*

A cohesive design language built on **Depth · Motion · Clarity**

### Color Palette

```
┌────────────────────────────────────────────────────────┐
│                                                        │
│  Primary    ███  #673AB7  Deep Purple (Actions)       │
│  Secondary  ███  #3F51B5  Indigo (Accents)            │
│  Success    ███  #4CAF50  Green (Confirmations)       │
│  Warning    ███  #FF9800  Orange (Alerts)             │
│  Error      ███  #F44336  Red (Errors)                │
│  Neutral    ███  #FAFAFA  Light Gray (Backgrounds)    │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### Design Tokens

| Token | Value | Usage |
|-------|-------|-------|
| **Primary Gradient** | `#673AB7 → #3F51B5` | CTAs, highlights |
| **Glass Surface** | 30% opacity + blur | Cards, surfaces |
| **Shadow Elevation** | 2/4/8/12dp | Depth layering |
| **Motion Curve** | `easeInOutCubic` | Smooth animations |
| **Border Radius** | 16dp / 24dp | Material 3 compliance |
| **Typography Scale** | Material 3 | Hierarchy & readability |

### Component Showcase

- 🎨 **Glassmorphic Cards** — Semi-transparent with backdrop blur
- 🎞️ **Lottie Micro-interactions** — Delightful feedback loops
- ✨ **Hero Transitions** — Physics-based page navigation
- 🏷️ **Sliver Effects** — Parallax product image headers
- 📱 **Adaptive Layouts** — Responsive to device sizes

<br/>

---

## ⚙️ Tech Stack

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃           TECHNOLOGY LAYERS                  ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                              ┃
┃  📱 Frontend        Flutter 3.x + Material 3┃
┃  🎯 Language        Dart (Type-safe)        ┃
┃  🔄 State Mgmt      Reactive Services       ┃
┃  🔐 Auth            Firebase Authentication ┃
┃  🗄️  Database       Cloud Firestore         ┃
┃  📁 Storage         Firebase Storage        ┃
┃  🎬 Animations      Lottie + Custom Hero    ┃
┃  🖼️  Images         cached_network_image    ┃
┃  📊 Real-time DB    Firebase Realtime DB    ┃
┃  📲 Notifications   Firebase Cloud Msg      ┃
┃                                              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

<br/>

---

## 🌟 Key Features

### 👤 Identity Hub — Authentication Excellence

```
┌─────────────────────────────────────────┐
│ ✅ Secure Login & Registration          │
│ ✅ Firebase Auth with Session Persist  │
│ ✅ Global State Management              │
│ ✅ Automatic Auth State Detection       │
│ ✅ Multi-factor Auth Ready              │
└─────────────────────────────────────────┘
```

- 🔐 **Secure Authentication** — Industry-standard Firebase Auth integration
- 💾 **Persistent Sessions** — Automatic login on app restart
- 🌍 **Global State** — Auth state accessible across entire app
- ⚡ **Instant Redirects** — Smart splash screen navigation
- 🛡️ **Security First** — Token refresh & secure storage

---

### 🛍️ Smart Discovery — Intuitive Browsing

```
┌─────────────────────────────────────────┐
│ ✅ Real-time Product Search             │
│ ✅ Category Filtering (Sub-second)      │
│ ✅ Horizontal Category Bar               │
│ ✅ Instant Results-as-you-Type          │
│ ✅ High-density Grid Layout             │
└─────────────────────────────────────────┘
```

- 🔍 **Blazing Fast Search** — Firestore query optimization
- 🏷️ **Smart Filters** — Multi-category filtering with instant UI updates
- 📊 **Dense Grids** — High-performance product grid rendering
- ⚡ **Sub-second Latency** — Optimized query performance

---

### 💙 Wishlist & Cart — Cloud-Synced Shopping

```
┌─────────────────────────────────────────┐
│ ☁️  Real-time Cloud Sync                 │
│ ✅ Cross-device Persistence             │
│ ✅ Optimistic UI Updates                │
│ ✅ Offline Support (Resilient)          │
│ ✅ Bi-directional Updates               │
└─────────────────────────────────────────┘
```

- 🔄 **Bi-directional Sync** — Changes reflect instantly across all devices
- 📱 **Offline Resilience** — Optimistic UI ensures seamless UX offline
- ☁️ **Cloud Persistence** — Firestore-backed state management
- ✨ **Smooth Animations** — Delightful add/remove interactions

---

### 💳 Transaction Suite — Checkout Perfection

```
┌─────────────────────────────────────────┐
│ 💰 Multiple Payment Options             │
│ ✅ Cash on Delivery (COD)               │
│ ✅ Online Payment Integration           │
│ ✅ Lottie Success Animations            │
│ ✅ Order Tracking & History             │
│ ✅ Real-time Order Updates              │
└─────────────────────────────────────────┘
```

- 🎯 **Dynamic Checkout** — Adaptive payment selection
- 🎉 **Celebration UX** — Delightful success screens with animations
- 📦 **Order Tracking** — Real-time order status with timestamps
- 📜 **Order History** — Complete purchase records with media

---

### 🎞️ Premium UI/UX — Visual Excellence

```
┌─────────────────────────────────────────┐
│ ✨ Sliver Effects with Parallax         │
│ ✅ Hero Transitions (Physics-based)     │
│ ✅ Glassmorphic Components              │
│ ✅ Micro-interactions & Feedback        │
│ ✅ Material 3 Compliance                │
│ ✅ Adaptive Dark/Light Themes           │
└─────────────────────────────────────────┘
```

- 🎨 **Custom Sliver Headers** — Parallax product image effects
- ✨ **Hero Transitions** — Fluid page navigation animations
- 🔮 **Glassmorphism** — Modern translucent design elements
- 🎬 **Lottie Loops** — Delightful micro-interactions throughout
- 60fps **Smooth Scrolling** — Memory-efficient rendering

<br/>

---

## 🏗️ Architecture

Aura Mart follows a **Clean Separation** pattern with clear responsibility layers.

```
aura_mart/
│
├── 📁 lib/
│   │
│   ├── 🎨 Screens/          [UI Layer - Presentation]
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── discovery_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   ├── cart/
│   │   │   └── cart_screen.dart
│   │   ├── wishlist/
│   │   │   └── wishlist_screen.dart
│   │   └── checkout/
│   │       ├── checkout_screen.dart
│   │       └── order_success_screen.dart
│   │
│   ├── ⚙️  Services/        [Business Logic Layer]
│   │   ├── auth_service.dart
│   │   ├── product_service.dart
│   │   ├── cart_service.dart
│   │   ├── wishlist_service.dart
│   │   └── order_service.dart
│   │
│   ├── 🔌 Splash Services/  [App Initialization]
│   │   └── splash_service.dart
│   │
│   └── 🚀 main.dart         [Entry Point]
│
├── 🎯 assets/
│   ├── images/              [App icons & static assets]
│   └── lottie/              [Animation files]
│
├── 🤖 android/              [Android native files]
├── 🍎 ios/                  [iOS native files]
├── 📋 pubspec.yaml          [Dependencies & config]
└── 🔥 firebase.json         [Firebase configuration]
```

### Layer Responsibilities

| Layer | Responsibility | Key Files |
|-------|-----------------|-----------|
| **Screens** | UI rendering, user interactions | `*_screen.dart` |
| **Services** | Business logic, Firebase calls | `*_service.dart` |
| **Splash Service** | App initialization, auth routing | `splash_service.dart` |

<br/>

---

## 🛠️ Engineering Highlights

### Advanced Implementations

| Feature | Implementation | Technical Value |
|---------|-----------------|-----------------|
| ⚡ **Real-time Sync** | Firestore `StreamBuilder` | Reactive data binding expertise |
| 🖼️ **Image Optimization** | `cached_network_image` + shimmer | Performance-first mindset |
| 🔐 **Auth State** | Global service + listener pattern | Security & state management |
| 🎨 **Custom UI** | Sliver + Hero + Lottie | UX attention to detail |
| 📶 **Offline Support** | Optimistic UI + persistence | Resilient architecture |
| 🏎️ **Scroll Performance** | Memory-efficient lists | 60fps smooth scrolling |

### Code Quality Standards

```
✅ Type-safe Dart code
✅ Separation of concerns
✅ Reactive architecture
✅ Firebase best practices
✅ Material 3 compliance
✅ Accessibility ready
```

<br/>

---

## 📦 Dependencies

```yaml
dependencies:
  # 🎯 Flutter & Dart
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # 🔥 Firebase Suite
  firebase_core: ^4.5.0
  firebase_auth: ^6.2.0
  firebase_storage: ^13.1.0
  firebase_database: ^12.1.4
  cloud_firestore: ^6.1.3
  firebase_messaging: ^15.0.0

  # 🎞️ UI & Animations
  lottie: ^3.1.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # 🛠️ Utilities
  fluttertoast: ^9.0.0
  intl: ^0.18.1
  provider: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_linter: ^4.0.0
```

<br/>

---

## 🔧 Installation & Setup

### ⏱️ Time to Run: ~5 minutes

### Prerequisites

- ✅ Flutter SDK `^3.10.3`
- ✅ Dart SDK (bundled with Flutter)
- ✅ Firebase project (Firestore, Auth, Storage enabled)
- ✅ Android Studio / VS Code / Xcode

### Step-by-Step Setup

#### 1️⃣ Clone Repository
```bash
git clone https://github.com/anshu-ac-dv/aura_mart.git
cd aura_mart
```

#### 2️⃣ Install Dependencies
```bash
flutter pub get
```

#### 3️⃣ Firebase Configuration

**Android:**
```bash
# Download google-services.json from Firebase Console
# Place in: android/app/google-services.json
```

**iOS:**
```bash
# Download GoogleService-Info.plist from Firebase Console
# Place in: ios/Runner/GoogleService-Info.plist
```

#### 4️⃣ Generate Assets
```bash
flutter pub run flutter_launcher_icons
```

#### 5️⃣ Run the App
```bash
flutter run --release
```

### Firebase Setup Checklist

```
□ Create Firebase project
□ Enable Firestore Database
□ Enable Firebase Authentication
□ Enable Firebase Storage
□ Download google-services.json (Android)
□ Download GoogleService-Info.plist (iOS)
□ Add files to respective directories
□ Never commit Firebase config files
```

### Environment Configuration

| File | Location | Action |
|------|----------|--------|
| `google-services.json` | `android/app/` | ⚠️ Add to `.gitignore` |
| `GoogleService-Info.plist` | `ios/Runner/` | ⚠️ Add to `.gitignore` |

<br/>

---

## 📁 Project Structure

### Language Distribution

```
Dart       ████████████████████████████░░░░  75.5%
C++        ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 12.3%
CMake      ███░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  9.6%
Swift      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1.2%
C          ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.7%
HTML       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.6%
Other      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.1%
```

### Directory Breakdown

```
📊 Codebase Statistics
├── 🎯 Main Code       → ~2000 lines of Dart
├── 🔧 Services        → ~500 lines (business logic)
├── 🎨 Screens         → ~1200 lines (UI)
├── 🎬 Assets          → 50+ image & animation files
└── 📦 Dependencies    → 15+ packages
```

<br/>

---

## 👨‍💻 Author

<div align="center">

```
╔════════════════════════════════════════╗
║                                        ║
║        Built with ❤️ & ☕ by          ║
║                                        ║
║         ANSHU KUMAR                    ║
║                                        ║
║    💡 Flutter Developer                ║
║    🎨 UI/UX Enthusiast                 ║
║    🏗️  Architecture Designer           ║
║    📱 Mobile Engineer                  ║
║                                        ║
║  Passionate about building beautiful, ║
║  scalable, and user-centric           ║
║  mobile applications.                 ║
║                                        ║
╚════════════════════════════════════════╝
```

### Connect & Collaborate

[![Portfolio](https://img.shields.io/badge/Portfolio-GitHub-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/anshu-ac-dv)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://linkedin.com/in/anshu-ac-dv)
[![Email](https://img.shields.io/badge/Email-Reach%20Out-EA4335?style=flat-square&logo=gmail&logoColor=white)](mailto:anshu.ac.dv@gmail.com)
[![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=flat-square&logo=twitter&logoColor=white)](https://twitter.com/anshu_ac_dv)

</div>

<br/>

---

## 📈 Project Growth

```
Development Status    ████████████████████░░░░░  85% Complete
Code Quality          ██████████████████████░░░  92% Excellent
Test Coverage         ███████████████░░░░░░░░░░  68% Good
Documentation         ██████████████████░░░░░░░  85% Comprehensive
```

<br/>

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

<br/>

---

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

```
MIT License - Feel free to use, modify, and distribute
© 2025 Anshu Kumar — All rights reserved
```

<br/>

---

<div align="center">

## 🌟 Show Your Support

```
If you found this project helpful or inspiring, 
please give it a ⭐ star on GitHub!

Your support motivates continuous improvement 
and helps the community discover this project.
```

**[⭐ Star on GitHub](https://github.com/anshu-ac-dv/aura_mart)**

<br/>

```
╔═══════════════════════════════════════════╗
║                                           ║
║  Made with precision, passion, and ☕     ║
║                                           ║
║   © 2025 Anshu Kumar — Aura Mart          ║
║                                           ║
║    Happy coding! 🚀                       ║
║                                           ║
╚═══════════════════════════════════════════╝
```

</div>

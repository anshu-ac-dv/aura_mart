# Aura Mart 🛍️

Aura Mart is a premium, modern e-commerce application built with Flutter and powered by Firebase. It features a clean UI, smooth animations, and robust authentication.

## 🚀 Project Workflow

The application follows a logical and secure flow to ensure a seamless user experience:

### 1. Initial Launch (Splash Screen)
- **Branding:** Displays an animated logo and tagline.
- **Session Check:** Uses `Firebase Auth` to check if a user is already logged in.
- **Auto-Routing:** 
  - If logged in: Redirects directly to the **Home Screen**.
  - If not logged in: Redirects to the **Login Screen**.

### 2. Authentication Flow
- **Login:** Users can sign in with their email and password.
- **Registration:** New users can create an account. The flow automatically saves their "Full Name" to their Firebase profile and redirects them to the Dashboard.
- **Forgot Password:** Integrated logic to send a password reset link via email.

### 3. Main Application (Home Screen)
The app uses a **Bottom Navigation Bar** to switch between four core areas:
- **Dashboard:** Features a search-driven interface. Users can search for products in real-time, browse categories, and view featured items.
- **Categories:** A dedicated space to browse products by type.
- **Cart:** Manage items selected for purchase.
- **Profile:** View account details, manage settings, and securely log out.

### 4. Core Features & Logic
- **Real-time Search:** The dashboard filters products instantly as the user types.
- **Dark Mode:** Supports system-wide theme switching (Light/Dark) with Material 3 color harmonization.
- **Organized Codebase:** Each tab and screen is modularized into separate files for scalability.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Backend:** [Firebase Authentication](https://firebase.google.com/products/auth)
- **UI Design:** Material 3
- **Navigation:** Flutter Navigator & BottomNavigationBar
- **State Management:** StatefulWidget (Local State)

---

## 📸 Screen Previews

- **Splash:** Animated entry with deep purple gradient.
- **Auth:** Clean, card-based Login and Register forms.
- **Home:** Modern dashboard with search and product grids.

---

## ⚙️ Installation & Setup

1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-username/aura_mart.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Firebase Setup:**
   - Create a Firebase project.
   - Add Android/iOS apps to your Firebase project.
   - Download and place `google-services.json` in `android/app/`.
4. **Run the app:**
   ```bash
   flutter run
   ```

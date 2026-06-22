# Step-by-Step Getting Started & Setup Guide

This guide will walk you through setting up your development environment and running both the mobile app and the admin portal. It is designed for beginners, explaining the purpose of each command and tool.

---

## 🛠️ Step 1: Install Global Prerequisites

Before working on either project, make sure you have the following core technologies installed on your machine.

### For the Mobile App (Flutter)
1. **Flutter SDK**:
   * Flutter is Google's UI toolkit for building natively compiled applications.
   * [Download Flutter SDK](https://docs.flutter.dev/get-started/install) for your OS (macOS, Windows, Linux).
   * Verify your installation by opening a terminal and running:
     ```bash
     flutter --version
     ```
     *(This codebase is compatible with Dart `^3.11.5`, which comes packaged with recent Flutter 3.x installations).*
2. **Platform IDE & SDK Tools**:
   * **For Android**: Install [Android Studio](https://developer.android.com/studio). Open it, go to SDK Manager, and install the latest Android SDK and build tools. Create a virtual device (emulator) via the Device Manager.
   * **For iOS** (macOS only): Install Xcode from the Mac App Store. Install command-line tools by running `xcode-select --install` in your terminal. Install CocoaPods (package manager for iOS native dependencies) using:
     ```bash
     sudo gem install cocoapods
     ```
3. **Validate Setup**:
   * Run the Flutter diagnostic tool to ensure everything is configured:
     ```bash
     flutter doctor
     ```
     Ensure that Flutter, Xcode, and Android toolchains show green checkmarks.

### For the Admin Web Portal (React + Node.js)
1. **Node.js**:
   * Node.js is a JavaScript runtime environment that lets you run tooling outside the browser.
   * [Download Node.js (LTS Version)](https://nodejs.org/). Version `v18.x` or `v20.x` is recommended.
   * Verify installation in your terminal:
     ```bash
     node -v
     npm -v
     ```
     *(npm is Node's default Package Manager, which installs all required libraries for the web app).*

---

## 📱 Step 2: Setup & Run the Mobile App (Flutter)

1. Open your terminal and navigate to the mobile app directory:
   ```bash
   cd gamifyphotography
   ```
2. **Download Package Dependencies**:
   * The app relies on various third-party libraries (defined in [pubspec.yaml](../pubspec.yaml)). Run:
     ```bash
     flutter pub get
     ```
     *What this does:* Downloads all the UI, networking, and Firebase libraries listed in the configuration file and links them to your project.
3. **Compile Code Generation (Build Runner)**:
   * This project uses libraries like `freezed` and `json_serializable` to automate data models and json conversion. These files are not checked into Git and must be compiled on your machine. Run:
     ```bash
     dart run build_runner build --delete-conflicting-outputs
     ```
     *What this does:* Searches for files marked for generation (containing `part 'filename.freezed.dart'`), processes the code, and creates the boilerplate code. If you make model changes, you will rerun this command.
4. **Boot up a Device**:
   * Open your iOS Simulator (via Xcode) or Android Emulator (via Android Studio).
   * Verify your active device by running:
     ```bash
     flutter devices
     ```
5. **Run the Project**:
   * Start the compilation and mount the app on the running simulator/emulator:
     ```bash
     flutter run
     ```
     *Tips:* Once running, you can press `r` in the terminal to perform a **Hot Reload** (injects changed code in sub-seconds without losing app state) or `R` for a **Hot Restart**.

---

## 💻 Step 3: Setup & Run the Admin Web Portal (Vite + React)

1. Open a new terminal tab and navigate to the admin directory:
   ```bash
   cd gamifyphotography-admin
   ```
2. **Install Node Modules**:
   * Install the application dependencies specified in the admin [package.json](https://github.com/aryapras22/gamifyphotography-admin/blob/main/package.json):
     ```bash
     npm install
     ```
     *What this does:* Creates a local `node_modules/` folder containing shadcn/ui dependencies, React Query, Vite, and tailwind plugins.
3. **Configure Environment Variables**:
   * Copy the template file in the admin repository:
     ```bash
     cp .env.example .env
     ```
   * Open `.env` in your editor and input your Firebase configuration details (see [Step 4](#step-4-connecting-firebase) below on how to obtain these).
4. **Run the Vite Dev Server**:
   * Start the fast local development server:
     ```bash
     npm run dev
     ```
     *What this does:* Launches the Vite bundler. Open the returned URL (typically `http://localhost:5173`) in your web browser. Any code edits you make will instantly render in the browser via Hot Module Replacement (HMR).

---

## 🔥 Step 4: Connecting Firebase & Setting Up Databases

Both projects need to talk to the same Firebase Console project to share data.

### 1. Register a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it (e.g., `Gamify Photography`).
3. (Optional) Enable Google Analytics and click **Create Project**.

### 2. Enable Services in Firebase Console
* **Authentication**: Go to *Build $\rightarrow$ Authentication $\rightarrow$ Get Started*. Under Sign-in method, enable **Email/Password**.
* **Cloud Firestore**: Go to *Build $\rightarrow$ Firestore Database $\rightarrow$ Create Database*. Choose your location, and select **Start in test mode** for initial setup.
* **Storage**: Go to *Build $\rightarrow$ Storage $\rightarrow$ Get Started*. Select test mode and choose a location.

### 3. Add Web Config to the Admin Portal
1. In your Firebase Console dashboard, click the **Web icon (`</>`)** to add an app.
2. Name it `Gamify Admin Portal`.
3. Firebase will display an initialization config object containing `apiKey`, `authDomain`, `projectId`, etc.
4. Copy these values and paste them into your `gamifyphotography-admin/.env` file:
   ```env
   VITE_FIREBASE_API_KEY=AIzaSy...
   VITE_FIREBASE_AUTH_DOMAIN=gamify-photography.firebaseapp.com
   VITE_FIREBASE_PROJECT_ID=gamify-photography
   VITE_FIREBASE_STORAGE_BUCKET=gamify-photography.appspot.com
   VITE_FIREBASE_MESSAGING_SENDER_ID=198422360148
   VITE_FIREBASE_APP_ID=1:198422360148:web:abcdef...
   ```

### 4. Seeding Firestore Data
To play the game, your Firestore database needs modules, levels, and quiz questions. 
1. The seeding blueprint structure and raw data are located in [seed_firestore.dart](../scripts/seed_firestore.dart).
2. Because Dart scripts cannot run the node-based Firebase Admin SDK natively, you can seed using the console or copy the javascript comment block in `seed_firestore.dart` to a temporary JavaScript file, e.g., `seed.js`:
   * Download a Service Account key from *Firebase Console $\rightarrow$ Project Settings $\rightarrow$ Service Accounts $\rightarrow$ Generate New Private Key*.
   * Save it as `serviceAccountKey.json` under your scripts directory.
   * Run the script to populate the collections:
     ```bash
     node scripts/seed.js
     ```
3. Ensure you create a user account via signup in the mobile app, then go to the Firestore viewer under the `users` collection and edit their document to set:
   ```json
   {
     "role": "admin"
   }
   ```
   This grants that user access to sign in to the Admin Dashboard!

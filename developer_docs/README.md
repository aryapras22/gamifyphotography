# Gamify Photography Developer Documentation Hub

Welcome! This directory contains detailed, beginner-friendly guides to help you understand, run, debug, and expand the **Gamify Photography** ecosystem.

Whether you are a junior developer, onboarding to this codebase for the first time, or an experienced developer coordinating changes with an AI Agent, these guides will help you navigate the codebase.

---

## 📱 What is Gamify Photography?

The **Gamify Photography** project is a gamified photography training platform designed to teach photography concepts (like the Rule of Thirds, Leading Lines, etc.) to corporate communications staff. It consists of two primary applications:

1. **Flutter Mobile Application (`gamifyphotography/`)**: 
   * A cross-platform app (Android & iOS) where players read educational modules, upload photo challenge submissions, score points, level up, unlock badges, and participate in leaderboards.
2. **React Admin Portal (`gamifyphotography-admin/`)**: 
   * A web-based operations dashboard where administrators inspect submission queues, grade photo composition quality, write feedback, manage user profiles, and view aggregate analytics.

Both components share a single **Firebase** backend:
* **Firebase Authentication**: Handles secure user registration, logins, and session persistence.
* **Cloud Firestore**: Holds user profiles, level details, quiz databases, and photo submission metadata.
* **Firebase Storage**: Stores uploaded photos submitted by users during photography challenges.

---

## 📚 Table of Contents

To help you get started quickly, we have separated the documentation into logical, bite-sized sections:

### 🚀 [1. Getting Started & Setup](getting_started.md)
* Learn step-by-step how to install prerequisites (Flutter, Node.js, npm, Firebase CLI).
* Follow instructions to get both apps running locally on your device or browser.
* Run the initial database seeding scripts to populate your local database.

### 🏛️ [2. Architecture, Features & Pages Guide](architecture_and_logic.md)
* Understand the **MVVM (Model-View-ViewModel)** architecture in the Flutter app.
* Understand the **Feature-Based Layout** architecture in the React admin app.
* Explore a comprehensive list and description of every screen, widget, and component in the codebase.

### 🔍 [3. Debugging & Troubleshooting](debugging_guide.md)
* Configure VS Code or Android Studio for step-by-step debugging (breakpoints, variable watch).
* Use state monitors (Riverpod DevTools, React Query DevTools).
* Troubleshoot common errors like Firebase App Check blockades, Firestore permissions, and form validation failures.

### 🛠️ [4. Changing Features & Pages](changing_features_and_pages.md)
* Step-by-step tutorial on how to add a new page or modify an existing screen.
* How to register routes in `GoRouter` (Flutter) and `React Router` (Web).
* **AI-Assisted Workflows**: Best practices for collaborating with the AI Coding Agent (Antigravity) to design, build, and verify changes safely.

### 🌐 [5. Deploying Documentation on GitHub](deploying_on_github.md)
* Learn how to view documentation natively on GitHub.
* Deploy a live HTML website using **GitHub Pages** from a `/docs` folder.
* Setup automated, custom docs page generators (like **Docsify**).

---

## 💡 Quick Tips for Beginners
* **Paths**: All file references in these guides use clickable links. If you are using an IDE like VS Code, you can click on them directly to open the referenced source file.
* **Terminal**: Keep two terminal windows open—one for the Flutter directory, and one for the React Admin directory—so you can run their respective compilation servers simultaneously.

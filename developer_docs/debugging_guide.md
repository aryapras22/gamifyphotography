# Debugging & Troubleshooting Guide

This guide details how to set up debugging environments, trace data states, and resolve common development blocks in the Gamify Photography codebase.

---

## 📱 1. Debugging the Flutter Mobile App

### IDE Breakpoints Setup
Instead of debugging using raw print statements, you should use interactive debugging.

#### In VS Code
1. Open the project in VS Code and install the **Dart** and **Flutter** extensions.
2. Create a file `.vscode/launch.json` at the root of the mobile folder:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Gamify Photography (Debug)",
         "request": "launch",
         "type": "dart"
       }
     ]
     }
   ```
3. Open any Dart file (e.g., [login_view.dart](../lib/views/auth/login_view.dart)), hover to the left of a line number, and click to set a **Red Dot (Breakpoint)**.
4. Press `F5`. When execution hits that line of code, the app will pause, allowing you to inspect variable values in the sidebar.

#### In Android Studio
1. Open the `gamifyphotography` folder.
2. Ensure the "Flutter Device Selection" dropdown has a device selected.
3. Click the **Bug Icon (Debug)** in the top right toolbar to start compilation with breakpoints enabled.

---

### Flutter DevTools
When running the app, Flutter provides a web-based suite of diagnostics called DevTools.
* In your terminal, running `flutter run` will output a DevTools URL. Copy and open it in Chrome.
* **Flutter Inspector**: Use the cursor pointer to click elements in your running simulator and trace their exact layout code.
* **Riverpod Provider Inspector**: Lets you see all active providers, their current state properties, and what view models are rebuild-dependent on them.

---

### Common Mobile Development Gotchas

#### 🔒 Firebase App Check Blocked Errors
* **The Symptom**: Network operations fail during Firestore writes or Storage uploads, showing "App Check failed" or permission blocked logs.
* **Why**: App Check ensures only authentic installations write data.
* **The Fix**: During development, we register a Debug Provider.
  1. Boot your app on an Android Emulator or iOS Simulator.
  2. View the console logs (either terminal or Logcat) and look for a line similar to:
     `Enter this debug token in the Firebase Console: XXXX-XXXX-XXXX-XXXX`
  3. Copy that token.
  4. Go to **Firebase Console** $\rightarrow$ **App Check** $\rightarrow$ **Apps** $\rightarrow$ Click your platform app $\rightarrow$ **Manage Debug Tokens**.
  5. Click **Add debug token**, paste your token, and click save. Re-run your application.

#### ⚙️ Code Generation is Out of Sync
* **The Symptom**: Build fails, complaining about missing classes, or files ending in `.g.dart` or `.freezed.dart`.
* **The Fix**: The code generators need to update. Run:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## 💻 2. Debugging the React Admin Portal

### Browser Diagnostics

#### 1. Checking DevTools Console
* If a page is showing a blank screen, open browser DevTools (`F12` or `Ctrl+Shift+I` / `Cmd+Option+I`) and look at the **Console** tab.
* Look for Firestore security rule exceptions (e.g. `Missing or insufficient permissions`) or React rendering errors.

#### 2. Network Tracing
* Use the **Network** tab to inspect Firestore database fetch requests.

---

### React Specific Tools

#### ⚛️ React Developer Tools
* Install the **React Developer Tools** browser extension.
* Inspect props, state dependencies, and trace how components are nested in the Admin layout.

#### 🔄 TanStack (React) Query Devtools
* React Query automatically caches queries (e.g., list of submissions).
* To visualize the queries in real-time, import the Devtools component in `main.tsx`:
  ```tsx
  import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
  
  // Render this inside your query provider context
  <ReactQueryDevtools initialIsOpen={false} />
  ```
  This adds a small floating badge in your browser that lets you inspect which queries are "fresh", "stale", or currently fetching.

---

### Common Admin Portal Gotchas

#### 🔑 Access Denied Redirect
* **The Symptom**: You log in successfully via Firebase Auth but are redirected to `/access-denied`.
* **Why**: The portal checks your role field in Firestore: `users/{userId}.role == 'admin'`.
* **The Fix**: Go to your Firestore database viewer in the Firebase Console, locate your user document, and verify that the `role` field is exactly set to `"admin"`.

#### 📝 Unresponsive Form Submissions
* **The Symptom**: Clicking "Submit Review" or "Save User" does not do anything, and no console network requests are fired.
* **Why**: React Hook Form validation failed.
* **The Fix**: Log your validation errors in the component:
  ```tsx
  const { register, handleSubmit, formState: { errors } } = useForm();
  console.log("Validation Errors:", errors);
  ```

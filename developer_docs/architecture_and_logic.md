# Architecture, Features & Pages Guide

This document explains the architectural patterns, state management logic, and feature layouts used in the mobile app and the admin portal.

---

## 🏛️ 1. Mobile App Architecture (Flutter)

The mobile application is written in Dart using the **Model-View-ViewModel (MVVM)** design pattern, backed by **Riverpod** for state injection and **GoRouter** for routing.

### The MVVM Paradigm

In MVVM, the system is separated into three distinct layers to prevent code tangling:

1. **Model (`lib/models/`)**: 
   * Simple, immutable data classes that represent data entities (e.g. `UserModel`, `ChallengeModel`). 
   * They only define fields and serializing methods (converting raw Firestore JSON maps to Dart objects).
2. **View (`lib/views/`)**: 
   * The visual layout constructed using Flutter Widgets.
   * **Rule**: Views must contain *zero business logic*. They only listen to ViewModels to display data and forward user taps to ViewModel methods.
3. **ViewModel (`lib/view_models/`)**: 
   * Manages the active state of a view.
   * Watches and calls **Services** to load or mutate data, updates its internal state, and notifies the view to repaint.
4. **Service (`lib/services/`)**: 
   * The execution engine that connects to external entities (Cloud Firestore databases, SharedPreferences memory, Firebase Storage).

---

### How State and Routing Work in Flutter

#### ⚡ Riverpod State Management
Instead of passing states manually through widget constructors, Riverpod acts as a global container of "Providers."
* **`ref.watch(provider)`**: Tells the View to listen to updates. Whenever the provider's state changes, the View updates automatically.
* **`ref.read(provider.notifier)`**: Grabs a direct reference to the ViewModel class to trigger methods (like submitting a login form) without listening for UI updates.

#### 🔀 GoRouter & Auth Guards
All application routes are defined in [router.dart](../lib/core/router.dart).
* **The `_AuthNotifier`**: Listens to changes in the user's login state (`authViewModelProvider`).
* **Redirect Logic**: If `auth.isLoggedIn` changes to `false`, the router automatically redirects the viewport to `/login`. If the user logs in, it pushes them to `/home`.

---

## 💻 2. Admin Web Portal Architecture (React)

The admin portal is structured as a **Feature-Based React Application** built with Vite, TypeScript, and Tailwind CSS.

### Key Architectural Choices

1. **Feature Directory Structure (`src/features/`)**:
   * Instead of sorting files by technical categories (e.g., placing all buttons in `components/`, all routes in `pages/`), files are co-located by **Business Features** (e.g., `submissions/`, `users/`, `dashboard/`).
   * Each feature folder houses its specific UI components, data hooks, and styles. This makes it easy for developers to find all files related to the "Review Queue" in one folder.
2. **shadcn/ui + Tailwind CSS**:
   * Located under `src/components/ui/` in the admin repository.
   * These are raw React elements styled via Tailwind utility classes.
3. **React Query (TanStack Query)**:
   * Used to manage server/Firestore states. 
   * It handles data fetching, loading flags, error boundaries, caching, and automatic invalidation (refetching data once an admin completes a review).

---

## 🔍 3. Detailed Feature & Page Catalog

Below is a detailed map of all features, their corresponding files, and logic in both applications.

### 📱 Mobile App Features & Pages (`gamifyphotography/lib/`)

#### 1. Onboarding & Authentication
* **Files**: 
  * View: `views/onboarding/onboarding_view.dart`, `views/auth/login_view.dart`, `views/auth/register_view.dart`
  * ViewModel: `view_models/auth_view_model.dart`
  * Service: [auth_service.dart](../lib/services/auth_service.dart)
* **Logic**: On first launch, the app reads SharedPreferences to see if onboarding is completed. If not, it shows onboarding slides. Users then sign up/log in. The `auth_service.dart` handles signing into Firebase Auth and updates the user profile record in Firestore.

#### 2. Main Dashboard & Routing Layout
* **Files**: 
  * Layout View: `views/home/main_layout_view.dart`
  * Sub-Tabs: `views/mission/` (Modules list), `views/progress/progress_view.dart` (XP and levels), `views/leaderboard/leaderboard_view.dart` (Rankings), `views/profile/profile_progress_view.dart` (Profile specs).
* **Logic**: Uses a bottom navigation bar to switch between sub-views. The active state controls which page displays.

#### 3. Educational Modules (Missions)
* **Files**: 
  * View: `views/mission/module_detail_view.dart`
  * ViewModel: `view_models/mission_view_model.dart`
  * Service: `services/module_service.dart`
* **Logic**: Reads lists of modules (e.g., Rule of Thirds) from the `modules` collection in Firestore. Displays structured materials, instructions, and examples.

#### 4. Uploading Challenges
* **Files**: 
  * View: `views/mission/challenge_view.dart`
  * ViewModel: `view_models/challenge_view_model.dart`
  * Service: `services/photo_submission_service.dart`
* **Logic**: Connects to the device camera using `camera` and `image_picker` plugins. Once a photo is selected:
  1. The photo is uploaded to Firebase Storage.
  2. A new document is written to the `photo_submissions` Firestore collection with `status = 'pending'`, along with the storage URL and user ID.

#### 5. User Progress, Streaks & Badges
* **Files**: 
  * View: `views/progress/progress_view.dart`
  * Services: `services/level_service.dart`, `services/badge_service.dart`
  * Models: `models/user_model.dart`
  * Logic: Calculate levels from current XP. If user completes challenges, `level_service` checks thresholds, handles leveling up, and unlocks relevant achievement badges.

---

### 💻 Admin Web Portal Features & Pages (`gamifyphotography-admin/src/`)

#### 1. Authentication Gate
* **Logic**: An admin logs in using Firebase Auth. Once logged in, the auth router checks the corresponding document in the `users` collection. If the user document has `role == "admin"`, access is granted. Otherwise, they are redirected to `/access-denied`.

#### 2. Dashboard KPIs
* **Logic**: Reads Firestore `photo_submissions` and `users` collections. Aggregates data on the fly (or via cached queries) to show total submissions, count of pending submissions, average score, and reviews completed today.

#### 3. Submissions Review Queue (The Core Workpage)
* **Logic**: Displays a split-screen layout:
  * **Left Side**: A filterable data table listing pending submissions.
  * **Right Side**: Detailed submission inspector. It loads the large image, user metadata, and displays a grading form.
  * **Actions**: Admins enter a score (0-100) and review notes. Clicking "Submit Review" performs a Firestore transaction:
    * Updates `photo_submissions` to `status = "approved"` (or reviewed).
    * Writes `adminScore`, `adminNote`, and `reviewedAt`.

#### 4. User Account Directory
* **Logic**: Fetches a grid list of registered users. Admin can query by email/name and modify user privileges (e.g. promoting a standard player to an "admin").

#### 5. Analytics Performance Charts
* **Logic**: Uses **Recharts** to parse and display weekly submission volume, average scores, and reviewer turnaround efficiency.

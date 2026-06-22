# How to Create and Change Pages & Features

This guide explains how to add new screens, modify existing pages, and collaborate with the AI Coding Agent (**Antigravity**) to perform these actions safely.

---

## 📱 1. Modifying & Creating Pages in Flutter

### How to Modify an Existing Feature
Let's say you want to add a text field or update the logic on an existing screen:
1. **Locate the View**: Views are stored under [lib/views/](../lib/views/). Find the target folder (e.g., `views/mission/challenge_view.dart`).
2. **Identify State Dependencies**: Check which provider the view watches. For example:
   ```dart
   final challengeState = ref.watch(challengeViewModelProvider);
   ```
3. **Modify the ViewModel**: If the update requires business logic changes (e.g., calling a new service endpoint or checking validation), open the corresponding ViewModel (in `lib/view_models/`). Modify the state class and actions.
4. **Compile Code Generation**: If you edit models (in `lib/models/`), always rebuild generated serializers:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

### How to Create a New Page (Step-by-Step)
Suppose you want to add a new "Settings Page" to the mobile app:

1. **Create the View File**:
   Create a new file `lib/views/profile/settings_view.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   
   class SettingsView extends ConsumerWidget {
     const SettingsView({super.key});
   
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(
         appBar: AppBar(title: const Text('Settings')),
         body: const Center(child: Text('Settings Options Go Here')),
       );
     }
   }
   ```
2. **Register the Route**:
   Open [lib/core/router.dart](../lib/core/router.dart). Add a new `GoRoute` to the routes array:
   ```dart
   GoRoute(
     path: '/settings',
     builder: (context, state) => const SettingsView(),
   ),
   ```
3. **Navigate to the Page**:
   In your profile widget or sidebar menu, hook up the navigation:
   ```dart
   ElevatedButton(
     onPressed: () => context.push('/settings'),
     child: const Text('Go to Settings'),
   );
   ```

---

## 💻 2. Modifying & Creating Pages in React Admin

### How to Modify an Existing Page
1. **Locate the Feature**: Features are stored in the admin repository's `src/features/`.
2. **Understand component bindings**: Forms use **React Hook Form** + **Zod**. If you are adding input fields, modify the schema definition.
3. **Update Queries**: If you need new data, update your hooks using standard React Query hooks.

---

### How to Create a New Page (Step-by-Step)
Let's add a new "Missions Editor" page in the admin portal:

1. **Create Feature Components**:
   Create a new directory `src/features/missions/` in the admin repo and add `MissionsPage.tsx`:
   ```tsx
   import React from 'react';
   import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
   
   export default function MissionsPage() {
     return (
       <div className="p-6">
         <Card>
           <CardHeader><CardTitle>Missions Management</CardTitle></CardHeader>
           <CardContent>Mission configuration controls...</CardContent>
         </Card>
       </div>
     );
   }
   ```
2. **Register the Page in Router**:
   Open `src/app/router.tsx` in the admin repo, import your component, and append the route config:
   ```tsx
   import MissionsPage from '@/features/missions/MissionsPage';
   
   // In routes array:
   {
     path: '/admin-missions',
     element: <MissionsPage />,
   }
   ```
3. **Add Navigation to Sidebar**:
   Open `src/app/layout.tsx` in the admin repo, locate the sidebar navigation lists, and add a link block:
   ```tsx
   <Link to="/admin-missions" className="flex items-center gap-2">
     <MapIcon className="h-5 w-5" />
     <span>Missions Config</span>
   </Link>
   ```

---

## 🤖 3. Working with the AI Coding Agent (Antigravity)

Using Antigravity to perform these updates makes adding pages and features much faster. 

### How to Frame Your Instructions
When asking the agent to make a code change:
1. **Specify data dependencies**: State which database collections and fields need to be read or modified in Firestore.
2. **Detail both ends**: If a feature spans both the Mobile app and the Web admin, request changes in both directories in a single prompt.
3. **Define validations**: Clearly state maximum characters, score limits, or mandatory fields.

---

### 💡 Example Prompt Scenario: Adding "Creativity Score"

Suppose you want to expand the photo submission grading. Currently, there is only a single `adminScore`. You want to introduce a sub-metric: **Creativity Score** (value 0-10) in addition to the main score, update both platforms, and save it in Firestore.

Copy-paste the prompt structure below to guide the AI Agent:

```markdown
Goal: Add a secondary grading field called "Creativity Score" (0 to 10 scale) to the photo submission review flow.

Please implement the following changes:

1. Database Model:
   - The photo submission documents in Firestore will now support an optional integer field: `creativityScore`.

2. React Admin Website (`gamifyphotography-admin/`):
   - Locate the submission review form schema (Zod validation in `src/features/submissions/`).
   - Add a new input field "Creativity Score" (dropdown or input from 0 to 10). It is mandatory before submitting a review.
   - When the admin submits a review, save this value to the Firestore document under the key `creativityScore`.
   - Update the reviewed submissions detail display to show "Creativity Score: X/10" next to the main score.

3. Mobile Application (`gamifyphotography/`):
   - Locate the submission detail model (in `lib/models/` or service serializers). Update the model to parsing the optional `creativityScore` field.
   - In the submission feedback view (where the user sees their feedback and score), display the Creativity Score value if it exists.

4. Verification:
   - Ensure the React build compilations pass without TypeScript errors.
   - Ensure the Flutter app compiles clean.
```

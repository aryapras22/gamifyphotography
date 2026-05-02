# tech-design.md — Mission (Core)

## Arsitektur Komponen

```
Views
├── ModuleListView        → ModuleCard (reusable widget)
├── ModuleDetailView      → PageView.builder (Page1: Teori | Page2: VisualGuide)
├── ChallengeBriefView
├── ChallengeView         → CameraPlaceholder → Navigator.push(CustomCameraView)
│                              ↳ setelah foto: uploadPhoto + completeChallenge + navigate /feedback
├── CustomCameraView      → [BARU] CameraPreview + SVG Overlay + ShutterButton
│                              ↳ return XFile via Navigator.pop(xfile)
└── FeedbackView          → PointsDisplay (Lottie belum diimplementasi)

ViewModels
├── MissionViewModel      (StateNotifier<MissionState>)
└── ChallengeViewModel    (StateNotifier<ChallengeState> — manual copyWith)

Services
├── ModuleService: getModules() — mock 10 misi lengkap
└── ChallengeService: getChallenge(moduleId), uploadPhoto(XFile), completeChallenge(id)

Providers (lib/providers/service_providers.dart)
├── authServiceProvider
├── challengeServiceProvider
├── moduleServiceProvider
└── userServiceProvider
```

---

## Data Models (Implementasi Aktual)

```dart
// ModuleModel — field sesuai implementasi di module_service.dart
@freezed
class ModuleModel with _$ModuleModel {
  factory ModuleModel({
    required String id,
    required String title,
    required String description,
    required String materialContent, // teks materi (bukan whenToUse/howToUse)
    required int order,              // urutan level
    @Default(false) bool isCompleted,
  }) = _ModuleModel;
  factory ModuleModel.fromJson(Map<String, dynamic> json) => _$ModuleModelFromJson(json);
}

// ChallengeModel
@freezed
class ChallengeModel with _$ChallengeModel {
  const factory ChallengeModel({
    required String id,
    required String moduleId,
    required String userId,
    required String instruction,     // teks instruksi challenge
    required int pointReward,
    @Default(false) bool isCompleted,
    String? uploadedPhotoUrl,
    DateTime? completedAt,
  }) = _ChallengeModel;
  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);
}

// ChallengeState — manual copyWith (bukan @freezed)
class ChallengeState {
  final ChallengeModel? challenge;
  final bool isUploading;
  final int pointsEarned;
  // ...
}
```

> **Catatan:** `ChallengeState` menggunakan manual `copyWith` karena tidak perlu serialisasi JSON. Menggunakan `@freezed` hanya dibutuhkan untuk model data yang disimpan/dibaca dari storage.

---

## Implementasi Kamera — CustomCameraView

```dart
// lib/views/mission/custom_camera_view.dart
// Flow: ChallengView → Navigator.push(CustomCameraView) → Navigator.pop(XFile)

class CustomCameraView extends StatefulWidget {
  final String moduleId; // untuk menentukan SVG overlay yang sesuai
}

// SVG overlay dipilih berdasarkan moduleId (M01–M10)
// Setiap misi punya visual guide grid yang berbeda:
// M01 → 01_rule_of_thirds.svg, M02 → 02_leading_lines.svg, dst.
```

### Fix 2: Centralize Service Providers
```dart
// lib/providers/service_providers.dart (SUDAH DIIMPLEMENTASI)
final moduleServiceProvider = Provider<ModuleService>((ref) => ModuleService());
final challengeServiceProvider = Provider<ChallengeService>((ref) => ChallengeService());
final userServiceProvider = Provider<UserService>((ref) => UserService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
```

---

## API Endpoints

```
GET  /api/modules
GET  /api/modules/:id
GET  /api/challenges/module/:moduleId
POST /api/challenges/:id/complete
     body: { photoUrl: String }
     response: { pointsEarned: int, newLevel: int, newTotalPoints: int }
```

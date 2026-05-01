# tech-design.md — Mission (Core)

## Arsitektur Komponen

```
Views
├── ModuleListView        → ModuleCard (reusable widget)
├── ModuleDetailView      → PageView.builder (Page1: Teori | Page2: VisualGuide)
├── ChallengeBriefView
├── ChallengeView         → CameraPreview + CapturedPhotoPreview
└── FeedbackView          → LottieAnimation + PointsDisplay

ViewModels
├── MissionViewModel      (StateNotifier<MissionState>)
└── ChallengeViewModel    (StateNotifier<ChallengeState>) — PERLU REFACTOR

Services
├── ModuleService: getModules(), getModuleById(id)
└── ChallengeService: getChallenge(moduleId), uploadPhoto(XFile), completeChallenge(id, url)
```

---

## Data Models (Setelah @freezed)

```dart
@freezed
class ModuleModel with _$ModuleModel {
  const factory ModuleModel({
    required String id,
    required String title,
    required String description,
    required String whenToUse,
    required String howToUse,
    required String exampleImageUrl,
    required String visualGuideUrl,
    @Default(100) int pointReward,
    @Default(false) bool isCompleted,
  }) = _ModuleModel;
  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);
}

@freezed
class ChallengeModel with _$ChallengeModel {
  const factory ChallengeModel({
    required String id,
    required String moduleId,
    required String userId,
    required int pointReward,
    @Default(false) bool isCompleted,
    String? uploadedPhotoUrl,
    DateTime? completedAt,
  }) = _ChallengeModel;
  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);
}
```

---

## Fix Wajib — ChallengeViewModel

### Fix 1: Ganti image_picker → camera package
```dart
// SESUDAH (benar):
Future<void> capturePhoto(CameraController controller) async {
  final XFile photo = await controller.takePicture();
  state = state.copyWith(capturedPhoto: photo);
}

Future<void> submitPhoto() async {
  if (state.capturedPhoto == null) return;
  state = state.copyWith(isUploading: true);
  try {
    final url = await _challengeService.uploadPhoto(state.capturedPhoto!);
    await _challengeService.completeChallenge(state.challenge!.id, url);
    final notifier = _ref.read(authViewModelProvider.notifier);
    final user = _ref.read(authViewModelProvider).currentUser!;
    notifier.updateUser(user.copyWith(
      points: user.points + state.challenge!.pointReward,
    ));
    state = state.copyWith(isUploading: false, isCompleted: true,
      pointsEarned: state.challenge!.pointReward);
  } catch (e) {
    state = state.copyWith(isUploading: false, errorMessage: e.toString());
  }
}
```

### Fix 2: Centralize Service Providers
```dart
// lib/providers/service_providers.dart
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

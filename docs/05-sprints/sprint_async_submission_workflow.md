# Sprint: Async Photo Submission & Admin Approval Workflow
**Sprint ID:** `SPR-007`
**Branch:** `feature/async-submission-workflow` ← **WAJIB dibuat sebelum development apapun**
**Base Branch:** `main`
**Repo:** [https://github.com/aryapras22/gamifyphotography](https://github.com/aryapras22/gamifyphotography)
**Priority:** 🔴 High
**Estimated Effort:** 4–5 hari kerja

---

## ⚠️ INSTRUKSI WAJIB UNTUK DEVELOPER AGENT

> Sebelum menulis **satu baris kode pun**, kamu **HARUS** menjalankan perintah berikut:
>
> ```bash
> git checkout main && git pull origin main
> git checkout -b feature/async-submission-workflow
> ```
>
> Seluruh perubahan di sprint ini dilakukan **hanya di branch ini**. Dilarang commit langsung ke `main`.

---

## RESEARCH MANDATE — Wajib Dilakukan Sebelum Implementation

> **Developer Agent diwajibkan melakukan riset teknis** sebelum memulai implementasi.
> Jangan berasumsi — baca kode yang ada, pahami arsitektur, lalu putuskan pendekatan terbaik.

### Pertanyaan Riset yang Harus Dijawab

Kamu **HARUS** membaca dan menganalisis file-file berikut terlebih dahulu:

| File | Yang Harus Dipahami |
|---|---|
| `lib/models/photo_submission_model.dart` | Field apa saja yang sudah ada? `status`, `adminNote`, `adminScore` sudah ada — pastikan tidak duplikat |
| `lib/models/module_model.dart` | Apakah perlu field baru `submissionStatus`? Atau cukup cross-reference dari `SubmissionViewModel`? |
| `lib/view_models/submission_view_model.dart` | Saat ini menggunakan `Future` (`get()`) — **apakah perlu diubah ke `Stream` (`snapshots()`)** untuk real-time update? |
| `lib/view_models/mission_view_model.dart` | Bagaimana `markModuleCompleted` saat ini bekerja? Apakah perlu dipisahkan antara "foto terkirim" vs "misi selesai diverifikasi"? |
| `lib/views/mission/` | Bagaimana UI submission saat ini? Di mana tombol upload foto dipanggil? |

### Pertanyaan Arsitektur yang Harus Diputuskan

1. **State management approach untuk real-time update:**
   - **Opsi A:** Ubah `SubmissionViewModel.loadUserSubmissions()` dari `Future` ke `Stream` menggunakan `snapshots()`. Ini membuat semua perubahan status dari admin langsung ter-reflect tanpa user perlu refresh.
   - **Opsi B:** Tetap `Future`, tambahkan `refreshSubmissions()` yang dipanggil saat user masuk ke halaman mission atau submission history.
   - **Rekomendasi awal:** Opsi A lebih unggul untuk UX karena admin approval bisa terjadi kapan saja. Kamu harus memverifikasi apakah arsitektur Riverpod yang ada mendukung `StreamNotifierProvider` atau tetap `StateNotifierProvider` dengan `StreamSubscription` manual.

2. **Apakah `ModuleModel` perlu field tambahan?**
   - Saat ini `ModuleModel` hanya punya `isCompleted: bool`.
   - Kamu perlu memutuskan apakah menambah field `submissionStatus: String?` langsung di `ModuleModel`, atau membiarkan UI melakukan cross-reference ke `SubmissionState.byModuleId[moduleId]?.status`.
   - **Rekomendasi:** Cross-reference lebih bersih — hindari denormalisasi data di model.

3. **Non-blocking progression logic:**
   - Saat ini `markModuleCompleted` langsung mark module sebagai selesai.
   - Dengan workflow baru: user submit foto → module masuk status **"pending"** → user BOLEH lanjut ke level berikutnya → admin review → status berubah ke **"approved"** atau **"rejected"**.
   - Kamu harus memutuskan kapan poin diberikan: saat submit (optimistic) atau saat approved (accurate). **Untuk skripsi, gunakan model: poin dasar saat submit, bonus poin dari `adminScore` saat approved.**

---

## Konteks Sistem Saat Ini

### Model yang Relevan (sudah ada, jangan dideklarasikan ulang)

**`PhotoSubmissionModel`** — field yang sudah tersedia:
```dart
String id
String userId
String userName
String moduleId
String moduleTitle
String photoUrl
String status          // 'pending' | 'approved' | 'rejected' — SUDAH ADA
String? adminNote      // feedback teks dari admin — SUDAH ADA
int? adminScore        // skor dari admin (0–100) — SUDAH ADA
DateTime submittedAt
DateTime? reviewedAt
```

**`ModuleModel`** — field saat ini:
```dart
String id
String title
String description
String materialContent
int order
bool isCompleted       // saat ini: false → true, tidak ada "pending" state
```

**`SubmissionViewModel`** — kondisi saat ini:
- Menggunakan `Future` (`get()`), bukan `Stream`
- Menyimpan submission terbaru per modul di `Map<String, PhotoSubmissionModel> byModuleId`
- Tidak ada real-time listener

**`MissionViewModel`** — kondisi saat ini:
- `markModuleCompleted(moduleId)` langsung set `isCompleted: true`
- Tidak mengetahui status submission

---

## USER STORY

```
Sebagai pengguna aplikasi (staf Corporate Communication SIG),
Saya ingin bisa mengunggah foto hasil misi, lalu langsung
melanjutkan ke misi berikutnya tanpa harus menunggu admin
meninjau foto saya,
Agar proses belajar saya tidak terhambat dan tetap berjalan
sambil menunggu feedback.

Dan ketika admin sudah meninjau foto saya,
Saya ingin melihat skor dan catatan dari admin langsung
di halaman misi tersebut,
Agar saya tahu seberapa baik teknik fotografi saya dan apa
yang perlu diperbaiki.
```

---

## DEFINITION OF DONE (DoD)

Sprint ini dianggap **selesai** jika semua checklist di bawah terpenuhi:

### State Management
- [ ] `SubmissionViewModel` menggunakan **real-time Stream** (`snapshots()`) bukan one-shot `get()`
- [ ] State di-update otomatis saat admin mengubah status di Firestore tanpa user perlu refresh
- [ ] `SubmissionState` memiliki enum/sealed class `SubmissionStatus` untuk `pending`, `approved`, `rejected`, `none`
- [ ] `MissionViewModel` bisa membaca status submission dari `SubmissionViewModel` untuk menentukan apakah modul "unlocked"

### Non-Blocking Progression
- [ ] Setelah submit foto, user **langsung bisa** menekan tombol lanjut ke modul berikutnya
- [ ] Modul berikutnya **tidak terkunci** selama submission sedang `pending`
- [ ] Poin dasar (dari `module.basePoints` atau nilai tetap sementara) **diberikan saat submit**
- [ ] Bonus poin dari `adminScore` **ditambahkan secara otomatis** saat status berubah dari `pending` → `approved`

### UI — Submission Screen
- [ ] Tombol "Kirim Foto" memunculkan image picker (kamera atau galeri)
- [ ] Setelah foto dipilih: tampilkan **preview foto** sebelum submit
- [ ] Loading state saat upload berlangsung (CircularProgressIndicator + teks "Mengunggah...")
- [ ] Setelah berhasil submit: tampilkan **status badge "Menunggu Review"** (warna amber/xpAmber) di card misi
- [ ] **Tidak ada double submission** — jika sudah ada submission `pending` atau `approved` untuk modul ini, tombol submit diganti dengan status badge

### UI — Review Result Display
- [ ] Jika status `approved`: tampilkan card hijau berisi **skor admin** (`adminScore`) dan **catatan admin** (`adminNote`)
- [ ] Jika status `rejected`: tampilkan card merah dengan **catatan admin** (`adminNote`) dan tombol **"Kirim Ulang"**
- [ ] Jika status `pending`: tampilkan card amber dengan teks "Foto sedang ditinjau admin..." dan timestamp `submittedAt`
- [ ] Jika belum ada submission (`none`): tampilkan tombol "Kirim Foto Misi"

### General
- [ ] `flutter analyze` zero errors
- [ ] Tidak ada hardcoded hex color — semua dari `AppColors`
- [ ] Tidak ada package baru di `pubspec.yaml`
- [ ] Semua file yang dimodifikasi harus dicatat di PR body

---

## TASK BREAKDOWN

### TASK 1 — Tambah `SubmissionStatus` Enum

**File baru:** `lib/models/submission_status.dart`

```dart
/// Enum terpusat untuk status submission.
/// Gunakan enum ini di seluruh codebase, jangan pakai String literal.
enum SubmissionStatus {
  none,       // user belum pernah submit
  pending,    // sudah submit, menunggu review admin
  approved,   // admin menyetujui
  rejected;   // admin menolak

  static SubmissionStatus fromString(String? value) {
    switch (value) {
      case 'pending':   return SubmissionStatus.pending;
      case 'approved':  return SubmissionStatus.approved;
      case 'rejected':  return SubmissionStatus.rejected;
      default:          return SubmissionStatus.none;
    }
  }

  bool get isSubmitted => this != SubmissionStatus.none;
  bool get allowsProgression => this != SubmissionStatus.none;
  bool get isReviewed => this == approved || this == rejected;
}
```

**DoD Task 1:**
- [ ] File baru dibuat di path yang benar
- [ ] Tidak ada import yang rusak
- [ ] `fromString(null)` mengembalikan `SubmissionStatus.none`

---

### TASK 2 — Ubah `SubmissionViewModel` ke Real-Time Stream

**File yang dimodifikasi:** `lib/view_models/submission_view_model.dart`

**Yang harus dilakukan:**
1. Ganti `Future<void> loadUserSubmissions()` dengan implementasi Stream-based menggunakan `snapshots()`
2. Simpan `StreamSubscription` agar bisa di-cancel saat ViewModel di-dispose
3. Expose method `watchUserSubmissions(String userId)` yang dipanggil sekali saat user login
4. Pertahankan `Map<String, PhotoSubmissionModel> byModuleId` sebagai struktur state

**Skeleton yang harus diimplementasikan:**

```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_submission_model.dart';
import '../models/submission_status.dart';

class SubmissionState {
  final Map<String, PhotoSubmissionModel> byModuleId;
  final bool isLoading;
  final String? errorMessage;

  const SubmissionState({
    this.byModuleId = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  SubmissionState copyWith({...}); // implementasi lengkap

  /// Helper: ambil status untuk modul tertentu
  SubmissionStatus statusFor(String moduleId) {
    final sub = byModuleId[moduleId];
    return SubmissionStatus.fromString(sub?.status);
  }

  /// Helper: ambil submission model (nullable) untuk modul tertentu
  PhotoSubmissionModel? submissionFor(String moduleId) => byModuleId[moduleId];
}

final submissionViewModelProvider =
    StateNotifierProvider<SubmissionViewModel, SubmissionState>(
        (ref) => SubmissionViewModel());

class SubmissionViewModel extends StateNotifier<SubmissionState> {
  final _db = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  SubmissionViewModel() : super(const SubmissionState());

  void watchUserSubmissions(String userId) {
    if (userId.isEmpty) return;
    _subscription?.cancel();
    state = state.copyWith(isLoading: true);

    _subscription = _db
        .collection('photo_submissions')
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final map = <String, PhotoSubmissionModel>{};
            for (final doc in snapshot.docs) {
              final data = doc.data();
              data['id'] = doc.id;
              if (data['submittedAt'] is Timestamp) {
                data['submittedAt'] =
                    (data['submittedAt'] as Timestamp).toDate().toIso8601String();
              }
              if (data['reviewedAt'] is Timestamp) {
                data['reviewedAt'] =
                    (data['reviewedAt'] as Timestamp).toDate().toIso8601String();
              }
              final model = PhotoSubmissionModel.fromJson(data);
              if (!map.containsKey(model.moduleId)) {
                map[model.moduleId] = model;
              }
            }

            // Deteksi transisi pending → approved untuk bonus poin
            for (final docChange in snapshot.docChanges) {
              if (docChange.type == DocumentChangeType.modified) {
                final data = docChange.doc.data()!;
                final newStatus = data['status'] as String?;
                final moduleId = data['moduleId'] as String?;
                final oldSub = moduleId != null ? state.byModuleId[moduleId] : null;
                if (newStatus == 'approved' && oldSub?.status == 'pending') {
                  final bonusPoints = (data['adminScore'] as int?) ?? 0;
                  if (bonusPoints > 0) {
                    // TODO: tambahkan bonus poin ke user via service
                  }
                }
              }
            }

            state = state.copyWith(isLoading: false, byModuleId: map);
          },
          onError: (e) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Gagal memuat data submission: $e',
            );
          },
        );
  }

  Future<void> submitPhoto({...}) async {
    // TODO: implementasi upload Storage + Firestore create
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

> ⚠️ `watchUserSubmissions` harus dipanggil dari `AuthViewModel` atau provider yang mendengarkan auth state change — bukan dari `initState` Widget.

**DoD Task 2:**
- [ ] `StreamSubscription` di-cancel saat dispose
- [ ] State ter-update otomatis saat Firestore data berubah
- [ ] `statusFor(moduleId)` dan `submissionFor(moduleId)` tersedia di `SubmissionState`
- [ ] Backward compatible: tidak ada caller lama yang rusak

---

### TASK 3 — Non-Blocking Progression di `MissionViewModel`

**File yang dimodifikasi:** `lib/view_models/mission_view_model.dart`

**Logika yang harus diubah:**

Saat ini: modul `n+1` baru terbuka jika modul `n` `isCompleted == true`.

Dengan workflow baru:
- Modul `n+1` terbuka jika modul `n` sudah disubmit (status `pending`, `approved`, atau `rejected`)
- `isCompleted` di `ModuleModel` tetap digunakan sebagai flag "modul sudah pernah selesai dikerjakan"
- Penentuan apakah tombol **lanjut** aktif menggunakan `SubmissionStatus.allowsProgression`

```dart
bool canProgressPastModule(String moduleId) {
  final isCompleted = state.modules
      .firstWhere((m) => m.id == moduleId, orElse: () => /* default */)
      .isCompleted;

  final submissionStatus = _ref
      .read(submissionViewModelProvider)
      .statusFor(moduleId);

  return isCompleted || submissionStatus.allowsProgression;
}
```

> **RESEARCH ITEM:** Verifikasi tidak ada circular dependency antara `MissionViewModel` dan `SubmissionViewModel`. Jika ada risiko, biarkan UI Widget yang membaca kedua provider.

**DoD Task 3:**
- [ ] Modul berikutnya bisa diakses saat submission modul sebelumnya berstatus `pending`
- [ ] Tidak ada circular dependency antar provider
- [ ] `markModuleCompleted` tetap berfungsi untuk backward compat

---

### TASK 4 — Redesign UI: Submission Panel di Module Detail View

**File yang dimodifikasi:** `lib/views/mission/module_detail_view.dart`
*(lakukan riset dulu di `lib/views/mission/` untuk memastikan nama file yang tepat)*

#### 4A — Status-Based Widget Switcher

```dart
Widget _buildSubmissionPanel(String moduleId) {
  final submission = ref.watch(submissionViewModelProvider)
      .submissionFor(moduleId);
  final status = SubmissionStatus.fromString(submission?.status);

  return switch (status) {
    SubmissionStatus.none     => _SubmitPhotoButton(moduleId: moduleId),
    SubmissionStatus.pending  => _PendingReviewCard(submission: submission!),
    SubmissionStatus.approved => _ApprovedResultCard(submission: submission!),
    SubmissionStatus.rejected => _RejectedResultCard(submission: submission!),
  };
}
```

#### 4B — `_PendingReviewCard`
```
┌──────────────────────────────────────────────────┐
│  🕐  Menunggu Review Admin                       │
│  Foto kamu sedang ditinjau. Kamu tetap bisa      │
│  melanjutkan misi berikutnya!                    │
│                                                  │
│  Dikirim: 14 Mei 2026, 10:30                     │
│  [Lihat Foto]                                    │
└──────────────────────────────────────────────────┘
```
- Background: `AppColors.streakBg` | Border: `AppColors.xpAmber`

#### 4C — `_ApprovedResultCard`
```
┌──────────────────────────────────────────────────┐
│  ✅  Foto Disetujui!                             │
│                                                  │
│  Skor Admin: ████████░░  80 / 100               │
│                                                  │
│  Catatan:                                        │
│  "Komposisi rule of thirds sudah bagus, tapi     │
│   perhatikan pencahayaan di foreground."         │
│                                                  │
│  Ditinjau: 14 Mei 2026, 14:00                    │
└──────────────────────────────────────────────────┘
```
- Background: `AppColors.forestGreen.withValues(alpha:0.08)` | Border: `AppColors.forestGreen`
- Skor bar: LinearProgressIndicator animasi 0 → adminScore, warna `AppColors.forestGreen`

#### 4D — `_RejectedResultCard`
```
┌──────────────────────────────────────────────────┐
│  ❌  Foto Ditolak                                │
│                                                  │
│  Catatan Admin:                                  │
│  "Foto terlalu gelap dan subjek tidak jelas."    │
│                                                  │
│  [ Kirim Ulang Foto ]                            │
└──────────────────────────────────────────────────┘
```
- Background: `AppColors.coralRed.withValues(alpha:0.08)` | Border: `AppColors.coralRed`

**DoD Task 4:**
- [ ] Keempat panel status ter-render dengan benar
- [ ] Tidak ada double submission
- [ ] Skor admin tampil sebagai progress bar animasi
- [ ] Catatan admin scrollable jika panjang
- [ ] Semua warna dari `AppColors`

---

### TASK 5 — Bonus Poin Otomatis saat Approved

Dalam stream listener `SubmissionViewModel`, deteksi transisi `pending → approved` dan panggil service untuk menambah `adminScore` sebagai bonus poin ke user.

**Guard wajib:** Hanya trigger saat `DocumentChangeType.modified`, bukan saat initial load (`DocumentChangeType.added`).

**DoD Task 5:**
- [ ] Bonus poin dari `adminScore` ditambahkan saat transisi `pending → approved`
- [ ] Tidak ada double-add
- [ ] Guard terhadap initial load event

---

### TASK 6 — Update Firestore Security Rules

```js
match /photo_submissions/{id} {
  allow read: if isAuthenticated()
    && (resource.data.userId == request.auth.uid || isAdmin());

  allow create: if isAuthenticated()
    && request.resource.data.userId == request.auth.uid
    && request.resource.data.status == 'pending'
    && request.resource.data.keys().hasAll(['userId','userName','moduleId',
         'moduleTitle','photoUrl','status','submittedAt'])
    && !request.resource.data.keys().hasAny(['adminNote','adminScore','reviewedAt']);

  allow update: if isAdmin()
    && request.resource.data.diff(resource.data)
        .affectedKeys().hasOnly(['status', 'adminNote', 'adminScore', 'reviewedAt']);

  allow delete: if false;
}
```

**DoD Task 6:**
- [ ] User tidak bisa set `adminScore` saat create
- [ ] Admin bisa update status + feedback fields
- [ ] Ditest di Firebase Console Simulator

---

## DATA FLOW DIAGRAM

```
USER ACTION                    FLUTTER STATE               FIRESTORE
─────────────────────────────────────────────────────────────────────

[Tap "Kirim Foto"]
        │
        ▼
[ImagePicker → preview]
        │
        ▼
[Tap "Konfirmasi & Kirim"]
        │                      SubmissionState.isLoading = true
        ├──────────────────────────────────────────────────────────►
        │                                              Upload Storage
        │                                              Create doc 'pending'
        ◄──────────────────────────────────────────────────────────┤
        │                      Stream listener triggered
        │                      byModuleId[moduleId] = submission
        │                      SubmissionStatus = pending
        │
        ▼
[UI render _PendingReviewCard]  ← otomatis via Stream
[Tombol "Lanjut" AKTIF]         ← allowsProgression = true

══════════════ ASYNC — KAPANPUN ADMIN REVIEW ══════════════

                               [Admin update Firestore]
                                    status = 'approved'
                                    adminScore = 80
                                    adminNote = "..."
                               ◄────────────────────────────
                               Stream listener triggered
                               Deteksi pending → approved
                               addBonusPoints(80)
                               ────────────────────────────►
                                    users/{uid}.points += 80

        ▼
[UI otomatis render _ApprovedResultCard]
[Skor 80/100 + catatan tampil]
```

---

## FILE YANG AKAN DIMODIFIKASI

| File | Action | Keterangan |
|---|---|---|
| `lib/models/submission_status.dart` | **CREATE** | Enum `SubmissionStatus` |
| `lib/view_models/submission_view_model.dart` | **MODIFY** | Future → Stream, helpers |
| `lib/view_models/mission_view_model.dart` | **MODIFY** | Non-blocking progression |
| `lib/views/mission/module_detail_view.dart` | **MODIFY** | Status-based submission panel |
| Firestore Rules | **MODIFY** | Via Firebase Console |

**File yang TIDAK BOLEH diubah:**
- `lib/models/photo_submission_model.dart` — sudah lengkap
- `lib/models/module_model.dart` — tidak perlu field baru
- `lib/main.dart` — login bypass tetap
- `lib/core/app_colors.dart` — sudah diatur sprint warna
- Semua `*.freezed.dart` dan `*.g.dart`

---

## PR REQUIREMENTS

**Branch:** `feature/async-submission-workflow`
**Base:** `main`
**Title:** `feat(SPR-007): async photo submission workflow with admin approval UI`

**Body PR wajib mencantumkan:**
1. Research findings — keputusan arsitektur (Stream vs Future, dependency injection)
2. Files changed — daftar lengkap
3. Screenshot/video — demo keempat panel (`none`, `pending`, `approved`, `rejected`)
4. Testing notes — cara manual test alur submit → pending → approved
5. Known limitations — hal yang tidak dikerjakan sprint ini

---

## NOTES TEKNIS PENTING

> **Tentang `docChanges` initial load:** Firestore `snapshots()` pertama kali mengembalikan semua dokumen sebagai `DocumentChangeType.added`. Guard logika deteksi `pending → approved` agar hanya jalan pada `DocumentChangeType.modified`.

> **Tentang `StreamSubscription` lifecycle:** Pastikan `_subscription?.cancel()` dipanggil di `override void dispose()`. Tanpa ini ada memory leak saat user logout.

> **Tentang `adminScore` null safety:** Selalu gunakan `submission.adminScore ?? 0`. Progress bar harus handle null dengan nilai 0 atau pesan "Skor belum diberikan".

# test-plan.md — Mission (Core)

## Unit Tests

| ID | Test | File |
|----|------|------|
| UT-M01 | `MissionViewModel`: state berubah jadi `isLoading=true` saat fetch | `test/view_models/mission_vm_test.dart` |
| UT-M02 | `MissionViewModel`: state berisi 10 modul setelah fetch sukses | `test/view_models/mission_vm_test.dart` |
| UT-M03 | `MissionViewModel`: state berisi `errorMessage` saat fetch gagal | `test/view_models/mission_vm_test.dart` |
| UT-M04 | `ChallengeViewModel`: `submitPhoto()` update poin user +100 | `test/view_models/challenge_vm_test.dart` |
| UT-M05 | `ChallengeViewModel`: `submitPhoto()` set `isCompleted=true` | `test/view_models/challenge_vm_test.dart` |
| UT-M06 | `ModuleModel.fromJson()` parsing benar | `test/models/module_model_test.dart` |

## Manual Checklist (Sebelum Demo Skripsi)

- [ ] Buka misi → halaman 1 tampil dengan benar
- [ ] Tap "Lihat Visual Guide" → pindah ke halaman 2
- [ ] Tap "Mulai Challenge" → kamera terbuka (bukan galeri)
- [ ] Ambil foto → preview muncul
- [ ] Tap "Retake" → kembali ke kamera
- [ ] Tap "Submit" → feedback view muncul dengan poin +100
- [ ] Misi yang sudah selesai ditandai centang di list
- [ ] Poin di home/profile bertambah setelah misi selesai
- [ ] Upload gagal → snackbar error muncul, tidak crash
- [ ] Izin kamera ditolak → dialog instruksi muncul

## Accessibility Checklist

- [ ] Semua tombol bisa di-tap tanpa mis-tap (min 44x44 logical pixel)
- [ ] Teks terbaca jelas di layar outdoor (kontras cukup)
- [ ] Loading state jelas (tidak freeze tanpa feedback)

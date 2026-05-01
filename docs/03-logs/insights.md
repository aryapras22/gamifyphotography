# insights.md — GamifyPhotography

> Pelajaran yang dipetik selama pengembangan. Update setelah setiap sprint/iterasi.

---

## Pola yang Harus DIULANGI ✅

- Routing sudah terstruktur dengan baik di `go_router` — pertahankan pattern ini
- Pemisahan View / ViewModel / Service sudah konsisten di fitur Mission — jadikan acuan
- Penggunaan `StateNotifier` di Riverpod sudah tepat — lanjutkan

## Pola yang Harus DIHINDARI ❌

- **Jangan buat Provider di dalam file ViewModel** (lihat BUG-05) — selalu taruh di `service_providers.dart`
- **Jangan import ViewModel dari ViewModel lain** (lihat BUG-04) — komunikasi hanya via service layer
- **Jangan mutasi model langsung** (lihat BUG-01, BUG-03) — selalu `copyWith`
- **Jangan tinggalkan mock bypass di production code** (lihat BUG-02) — gunakan feature flag yang eksplisit

## Keputusan yang Mempercepat Development

_Akan diisi seiring progress coding_

## Keputusan yang Memperlambat Development

_Akan diisi seiring progress coding_

## Catatan untuk Iterasi Berikutnya

- Pertimbangkan `go_router` redirect untuk auth guard (saat ini belum ada)
- Pertimbangkan `hive` atau `shared_preferences` untuk cache poin lokal
- Jika konten misi berkembang, pertimbangkan CMS sederhana daripada hardcode

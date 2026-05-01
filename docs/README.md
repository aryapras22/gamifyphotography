# 📚 GamifyPhotography — Dokumentasi Spec-Driven Development

Dokumentasi ini dirancang untuk mendukung **vibe coding** bersama AI agar tetap konsisten,
terarah, dan tidak kehilangan konteks di setiap sesi.

---

## 🗂️ Struktur Folder

```
docs/
├── README.md
├── 00-context/
│   ├── vision.md          ← Tujuan, target user, batasan, tech stack
│   ├── assumptions.md     ← Asumsi produk & teknis + risiko
│   └── system-state.md    ← Status kode terkini + known issues
├── 01-product/
│   └── prd.md             ← User stories + acceptance criteria
├── 02-features/
│   ├── mission/           ← feature-spec, tech-design, dev-tasks, test-plan
│   ├── daily-login/       ← feature-spec, dev-tasks
│   ├── badge/             ← feature-spec, dev-tasks
│   ├── crafting/          ← feature-spec, dev-tasks
│   ├── leaderboard/       ← feature-spec, dev-tasks
│   └── profile/           ← feature-spec, dev-tasks
└── 03-logs/
    ├── implementation-log.md
    ├── decisions-log.md
    ├── bug-log.md
    ├── validation-log.md
    └── insights.md
```

---

## 🚀 Cara Menggunakan untuk Vibe Coding

### Template Prompt Pembuka Setiap Sesi AI

```
Kamu adalah Senior Flutter Developer.

[KONTEKS PROYEK]
{paste isi vision.md}

[STATUS KODE SAAT INI]
{paste isi system-state.md}

[TASK YANG DIKERJAKAN HARI INI]
{paste 1-3 task dari dev-tasks.md}

Mulai dari task pertama. Tanya saya jika ada yang tidak jelas.
Selalu gunakan @freezed untuk model baru dan copyWith untuk update state.
Jangan pernah mutasi field model secara langsung.
```

### Loop Harian

1. Pilih 1–3 task dari `02-features/{fitur}/dev-tasks.md`
2. Buka sesi AI dengan template di atas
3. Implement + test
4. Update `system-state.md` (centang bug yang sudah fix)
5. Tambah entry di `03-logs/implementation-log.md`
6. Commit ke Git

---

## 🔴 Critical Fixes — Kerjakan Sebelum Fitur Baru

| Priority | Task | File | Bug ID |
|----------|------|------|--------|
| 1 | Buat `service_providers.dart` | `lib/providers/` | BUG-04, BUG-05 |
| 2 | Konversi semua Model ke `@freezed` | `lib/models/*.dart` | BUG-03, BUG-06 |
| 3 | Fix state mutation di ChallengeViewModel | `challenge_view_model.dart` | BUG-01 |
| 4 | Ganti `image_picker` → `camera` package | `challenge_view_model.dart` | BUG-07 |
| 5 | Hapus mock bypass login | `auth_view_model.dart` | BUG-02 |

---

## 📊 MVP Progress Tracker

| Fitur | Spec | Tech Design | Dev Tasks | Implementasi | Test |
|-------|------|-------------|-----------|--------------|------|
| Mission (Core) | ✅ | ✅ | ✅ | 🔄 25% | ❌ |
| Daily Login | ✅ | ⏳ | ✅ | ❌ 0% | ❌ |
| Badge System | ✅ | ⏳ | ✅ | ❌ 20% | ❌ |
| Crafting | ✅ | ⏳ | ✅ | 🔄 45% | ❌ |
| Leaderboard | ✅ | ⏳ | ✅ | 🔄 20% | ❌ |
| Profile + Galeri | ✅ | ⏳ | ✅ | ❌ 0% | ❌ |
| Firebase Auth | ⏳ | ⏳ | ⏳ | ❌ 0% | ❌ |

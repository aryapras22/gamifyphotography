# prd.md — Product Requirements Document
# GamifyPhotography MVP

## Overview

Aplikasi gamifikasi pelatihan fotografi untuk staf Corporate Communication SIG.
MVP berfokus pada 7 fitur inti dengan 10 misi Komposisi sebagai konten awal.

---

## EPIC-01: Onboarding & Autentikasi

**US-01** — As a new user, I want to see an onboarding screen so that I understand the app.
- AC1: Minimal 3 slide penjelasan fitur utama
- AC2: Tombol "Mulai" menuju halaman register
- AC3: User yang sudah login langsung ke home (skip onboarding)

**US-02** — As a new user, I want to register with name, email, and password.
- AC1: Validasi: nama (wajib), email (format valid), password (min 8 karakter)
- AC2: Register berhasil → langsung masuk home
- AC3: Email sudah terdaftar → tampilkan error yang jelas

**US-03** — As a registered user, I want to log in with email and password.
- AC1: Login berhasil → navigasi ke `/home`
- AC2: Login gagal → tampilkan error message (tidak crash)
- AC3: Sesi login persisten (tidak logout saat app ditutup)

---

## EPIC-02: Daily Login

**US-04** — As a logged-in user, I want a daily login popup to claim bonus points.
- AC1: Popup muncul otomatis pertama kali buka app setiap hari baru
- AC2: Tampilkan progress 7-hari streak
- AC3: Tombol "Claim" memberikan +50 poin
- AC4: Setelah di-claim, popup tidak muncul lagi hari yang sama
- AC5: Streak reset ke hari 1 jika tidak login lebih dari 1 hari

---

## EPIC-03: Mission (Core)

**US-05** — As a user, I want to see a list of missions so that I know what to learn.
- AC1: 10 misi Komposisi (nama, deskripsi singkat, status selesai/belum)
- AC2: Misi selesai ditandai centang, tidak bisa diulang

**US-06** — As a user, I want to read theory on page 1 of a mission.
- AC1: Judul + deskripsi + contoh foto ilustrasi
- AC2: Tombol navigasi ke Halaman 2

**US-07** — As a user, I want to read the visual guide on page 2.
- AC1: Kapan digunakan + cara menggunakan + gambar visual guide
- AC2: Tombol "Mulai Challenge"

**US-08** — As a user, I want to take a photo with my camera to complete the mission.
- AC1: Membuka kamera native device (BUKAN galeri)
- AC2: User bisa retake sebelum submit
- AC3: Submit berhasil → +100 poin
- AC4: Foto tersimpan dan tampil di halaman Profile
- AC5: Halaman Feedback tampil: poin + animasi selebrasi

---

## EPIC-04: Leaderboard

**US-09** — As a user, I want to see the leaderboard ranked by total points.
- AC1: Semua user terdaftar, urut descending berdasarkan total poin
- AC2: Per baris: ranking, nama, total poin
- AC3: User yang sedang login di-highlight

---

## EPIC-05: Profile

**US-10** — As a user, I want to see my identity and earned badges on my profile.
- AC1: Tampil: nama, email, level, total poin
- AC2: Badge diperoleh tampil penuh; badge terkunci tampil abu-abu

**US-11** — As a user, I want to scroll down to see my photo gallery.
- AC1: Galeri foto dari hasil submit challenge misi (grid 2 kolom)
- AC2: Tap foto → popup detail (nama misi + tanggal submit)
- AC3: Empty state jika belum ada foto

---

## EPIC-06: Badge System

**US-12** — As a user, I want to automatically receive a badge when I meet the criteria.
- AC1: **Badge Starter** — misi pertama selesai → +100 poin
- AC2: **Badge Rookie** — capai level 15 → +100 poin
- AC3: **Badge Veteran** — capai level 30 → +100 poin
- AC4: **Badge Special Mission** — special misi level 10 → +100 poin
- AC5: **Badge Survivor** — 7-day login streak selesai → +100 poin
- AC6: Notifikasi in-app saat badge pertama kali diperoleh
- AC7: Badge hanya diberikan satu kali

---

## EPIC-07: Crafting

**US-13** — As a user, I want to see my bridge-building progress.
- AC1: Visual jembatan berubah di milestone: 0–1.999 / 2.000–3.999 / 4.000–4.999 / 5.000+
- AC2: Progress bar: X / 5.000 poin
- AC3: Animasi Lottie satu kali saat milestone baru tercapai

---

## Prioritas MVP

| Priority | Epic | Keterangan |
|----------|------|------------|
| P0 Must Have | Mission (Core) | Selesai sebelum uji coba |
| P0 Must Have | Crafting | Selesai sebelum uji coba |
| P1 Should Have | Badge System | Penting untuk motivasi |
| P1 Should Have | Daily Login | Penting untuk retensi |
| P1 Should Have | Leaderboard | Penting untuk kompetisi |
| P2 Nice to Have | Profile + Galeri | Bisa iterasi setelah uji coba |
| P3 Later | Firebase Auth | Setelah mock phase selesai |

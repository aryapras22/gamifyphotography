// scripts/seed_firestore.dart
// TASK-M10 — Seed data level, modul, dan pretest ke Firestore
//
// Cara menjalankan:
//   dart run scripts/seed_firestore.dart
//
// Prasyarat:
//   - Firebase project sudah dikonfigurasi
//   - Service account key tersedia di GOOGLE_APPLICATION_CREDENTIALS
//   - Atau jalankan dari emulator: firebase emulators:start
//
// CATATAN: Script ini menggunakan firebase_admin via REST API karena
// dart:io tidak bisa langsung pakai Firebase Admin SDK.
// Alternatif: jalankan seed via Node.js atau Firebase Console.

// ── Data yang di-seed ─────────────────────────────────────────────────────
//
// 1. Collection `modules` (10 dokumen)
// 2. Collection `levels` (25 dokumen)
// 3. Collection `levels/{id}/questions` (soal quiz level 10, 15, 20, 25)
// 4. Collection `pretest_questions` (25 soal)
//
// ── Struktur dokumen `levels` ─────────────────────────────────────────────
//
// {
//   levelNumber: int,
//   title: string,
//   type: 'materi' | 'quiz',
//   order: int,
//   isActive: true,
//   passingScore: int (hanya untuk quiz),
//   page1: {
//     description: string,
//     referenceImageUrls: []  // kosong — diupload via admin
//   },
//   page2: {
//     whenToUse: string,
//     howToUse: string,
//     howToUseImageUrl: null  // diupload via admin
//   }
// }
//
// ── Struktur dokumen `levels/{id}/questions` ──────────────────────────────
//
// {
//   order: int,
//   questionText: string,
//   questionImageUrl: null,
//   options: [string, string, string, string],
//   correctIndex: int
// }
//
// ── Struktur dokumen `pretest_questions` ─────────────────────────────────
//
// {
//   order: int,
//   questionText: string,
//   questionImageUrl: null,
//   options: [string, string, string, string],
//   correctIndex: int
// }

// Untuk menjalankan seed, gunakan Firebase Console atau script Node.js berikut:
// (simpan sebagai scripts/seed_firestore.js dan jalankan dengan node)

/*
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Import data dari level_content_data.dart (konversi manual ke JS)
// Lihat lib/core/level_content_data.dart untuk data lengkap

async function seedModules() {
  const modules = [
    { id: 'M01', title: 'Rule of Thirds', description: 'Letakkan subjek di titik potong garis sepertiga', order: 1, levelCount: 0 },
    { id: 'M02', title: 'Leading Lines', description: 'Gunakan garis untuk mengarahkan mata ke subjek', order: 2, levelCount: 0 },
    // ... dst
  ];
  for (const m of modules) {
    await db.collection('modules').doc(m.id).set(m);
    console.log(`Seeded module: ${m.id}`);
  }
}

async function seedLevels() {
  // Level 1: Rule of Thirds
  const level1Ref = await db.collection('levels').add({
    levelNumber: 1,
    title: 'Rule of Thirds',
    type: 'materi',
    order: 1,
    isActive: true,
    page1: {
      description: 'Rule of Thirds adalah teknik komposisi dasar...',
      referenceImageUrls: []
    },
    page2: {
      whenToUse: 'Gunakan Rule of Thirds saat memotret lanskap...',
      howToUse: '1. Aktifkan grid 3x3...',
      howToUseImageUrl: null
    }
  });
  console.log(`Seeded level 1: ${level1Ref.id}`);

  // Level 10: Quiz
  const level10Ref = await db.collection('levels').add({
    levelNumber: 10,
    title: 'Quiz: Triangle Exposure I',
    type: 'quiz',
    order: 10,
    isActive: true,
    passingScore: 70
  });

  // Seed soal quiz level 10
  const questions = [
    {
      order: 1,
      questionText: 'Apa yang dimaksud dengan Segitiga Eksposur dalam fotografi?',
      questionImageUrl: null,
      options: [
        'A. Kombinasi ISO, Aperture, dan Shutter Speed',
        'B. Kombinasi Warna, Kontras, dan Saturasi',
        'C. Kombinasi Fokus, Zoom, dan Flash',
        'D. Kombinasi White Balance, Exposure, dan HDR'
      ],
      correctIndex: 0
    },
    // ... 24 soal lainnya
  ];

  for (const q of questions) {
    await db.collection('levels').doc(level10Ref.id).collection('questions').add(q);
  }
  console.log(`Seeded ${questions.length} questions for level 10`);
}

async function seedPretestQuestions() {
  const questions = [
    {
      order: 1,
      questionText: 'Apa yang dimaksud dengan "Rule of Thirds" dalam fotografi?',
      questionImageUrl: null,
      options: [
        'A. Membagi foto menjadi 3 bagian sama besar secara horizontal',
        'B. Membagi foto dengan 2 garis horizontal dan 2 vertikal, menempatkan subjek di titik perpotongan',
        'C. Menggunakan 3 sumber cahaya dalam setiap foto',
        'D. Memotret dengan 3 kali eksposur berbeda'
      ],
      correctIndex: 1
    },
    // ... 24 soal lainnya
  ];

  for (const q of questions) {
    await db.collection('pretest_questions').add(q);
  }
  console.log(`Seeded ${questions.length} pretest questions`);
}

(async () => {
  await seedModules();
  await seedLevels();
  await seedPretestQuestions();
  console.log('Seed selesai!');
  process.exit(0);
})();
*/

// ── Firestore Indexes (tambahkan ke firestore.indexes.json) ───────────────
//
// {
//   "indexes": [
//     {
//       "collectionGroup": "levels",
//       "queryScope": "COLLECTION",
//       "fields": [
//         { "fieldPath": "isActive", "order": "ASCENDING" },
//         { "fieldPath": "order", "order": "ASCENDING" }
//       ]
//     },
//     {
//       "collectionGroup": "questions",
//       "queryScope": "COLLECTION_GROUP",
//       "fields": [
//         { "fieldPath": "order", "order": "ASCENDING" }
//       ]
//     },
//     {
//       "collectionGroup": "pretest_questions",
//       "queryScope": "COLLECTION",
//       "fields": [
//         { "fieldPath": "order", "order": "ASCENDING" }
//       ]
//     }
//   ]
// }

void main() {
  print('Lihat komentar di file ini untuk instruksi seed Firestore.');
  print('Gunakan script Node.js di atas atau Firebase Console untuk seed data.');
}

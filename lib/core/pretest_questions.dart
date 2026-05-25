// lib/core/pretest_questions.dart
// TASK-08 — Soal Pretest & Posttest (25 soal, sama persis)
// Soal ini digunakan untuk PRETEST (setelah Level 1) dan POSTTEST (setelah crafting selesai)

import '../models/level_model.dart';

class PretestQuestions {
  PretestQuestions._();

  static const List<QuizQuestion> questions = [
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "Rule of Thirds" dalam fotografi?',
      options: [
        'A. Membagi foto menjadi 3 bagian sama besar secara horizontal',
        'B. Membagi foto dengan 2 garis horizontal dan 2 vertikal, menempatkan subjek di titik perpotongan',
        'C. Menggunakan 3 sumber cahaya dalam setiap foto',
        'D. Memotret dengan 3 kali eksposur berbeda',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "aperture" dalam fotografi?',
      options: [
        'A. Kecepatan rana kamera',
        'B. Sensitivitas sensor terhadap cahaya',
        'C. Bukaan lensa yang mengontrol jumlah cahaya masuk',
        'D. Jarak fokus lensa',
      ],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "shutter speed"?',
      options: [
        'A. Kecepatan autofokus kamera',
        'B. Lamanya rana terbuka saat memotret',
        'C. Kecepatan transfer foto ke memori',
        'D. Kecepatan motor zoom lensa',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'ISO dalam fotografi mengacu pada...',
      options: [
        'A. Ukuran sensor kamera',
        'B. Kecepatan rana',
        'C. Sensitivitas sensor terhadap cahaya',
        'D. Bukaan lensa',
      ],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "depth of field" (DoF)?',
      options: [
        'A. Jarak maksimum yang bisa difoto kamera',
        'B. Rentang jarak dalam foto yang tampak tajam',
        'C. Kedalaman warna dalam foto',
        'D. Jarak antara kamera dan subjek',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Teknik "bokeh" dalam fotografi menghasilkan...',
      options: [
        'A. Foto yang sangat tajam di seluruh area',
        'B. Efek blur artistik pada latar belakang',
        'C. Foto dengan warna yang sangat jenuh',
        'D. Efek gerakan pada foto',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "white balance" dalam fotografi?',
      options: [
        'A. Keseimbangan antara area terang dan gelap',
        'B. Pengaturan untuk mereproduksi warna putih secara akurat sesuai kondisi cahaya',
        'C. Jumlah piksel putih dalam foto',
        'D. Kecerahan keseluruhan foto',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "leading lines" dalam komposisi foto?',
      options: [
        'A. Garis tepi foto',
        'B. Garis dalam foto yang mengarahkan pandangan ke subjek utama',
        'C. Garis grid di viewfinder',
        'D. Garis horizon dalam foto landscape',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "negative space" dalam fotografi?',
      options: [
        'A. Area gelap dalam foto',
        'B. Area kosong di sekitar subjek utama',
        'C. Foto yang diambil dengan eksposur negatif',
        'D. Bayangan dalam foto',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Untuk memotret objek bergerak cepat tanpa blur, shutter speed yang tepat adalah...',
      options: [
        'A. 1/30s',
        'B. 1/60s',
        'C. 1/500s atau lebih cepat',
        'D. 2 detik',
      ],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "framing" dalam komposisi foto?',
      options: [
        'A. Memilih ukuran cetak foto',
        'B. Menggunakan elemen di sekitar subjek sebagai bingkai alami',
        'C. Mengatur batas foto saat editing',
        'D. Memilih orientasi foto (landscape/portrait)',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "golden hour" dalam fotografi?',
      options: [
        'A. Jam 12 siang saat cahaya paling terang',
        'B. Periode sekitar 1 jam setelah matahari terbit dan sebelum terbenam',
        'C. Waktu terbaik untuk foto indoor',
        'D. Saat menggunakan filter kuning',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "exposure" dalam fotografi?',
      options: [
        'A. Jenis lensa yang digunakan',
        'B. Jumlah cahaya yang diterima sensor saat memotret',
        'C. Ukuran file foto',
        'D. Resolusi foto',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "symmetry" dalam komposisi foto?',
      options: [
        'A. Foto yang diambil dari sudut simetris',
        'B. Keseimbangan visual di mana satu sisi mencerminkan sisi lainnya',
        'C. Menggunakan dua kamera sekaligus',
        'D. Foto dengan dua subjek yang identik',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "fill flash" dalam fotografi?',
      options: [
        'A. Flash yang mengisi seluruh ruangan',
        'B. Flash yang digunakan untuk mengisi bayangan pada subjek di kondisi cahaya terang',
        'C. Flash yang digunakan di dalam studio',
        'D. Flash dengan daya penuh',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "histogram" dalam fotografi?',
      options: [
        'A. Grafik yang menunjukkan distribusi kecerahan dalam foto',
        'B. Daftar pengaturan kamera',
        'C. Grafik yang menunjukkan komposisi foto',
        'D. Riwayat foto yang diambil',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "panning" dalam fotografi?',
      options: [
        'A. Memotret dari sudut atas',
        'B. Mengikuti gerakan subjek dengan kamera saat memotret untuk efek blur latar',
        'C. Memotret panorama',
        'D. Menggunakan tripod saat memotret',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "silhouette" dalam fotografi?',
      options: [
        'A. Foto dengan warna yang sangat cerah',
        'B. Foto subjek sebagai bentuk gelap di depan latar terang',
        'C. Foto dengan efek bayangan panjang',
        'D. Foto yang diambil saat matahari terbenam',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "macro photography"?',
      options: [
        'A. Foto dengan lensa telephoto panjang',
        'B. Foto dengan perbesaran tinggi untuk menangkap detail objek kecil',
        'C. Foto panorama lebar',
        'D. Foto dengan banyak subjek',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "composition" dalam fotografi?',
      options: [
        'A. Pengaturan teknis kamera',
        'B. Cara mengatur elemen visual dalam frame foto',
        'C. Proses editing foto',
        'D. Jenis kamera yang digunakan',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "RAW format" dalam fotografi digital?',
      options: [
        'A. Format foto yang sudah dikompresi',
        'B. Format foto yang menyimpan semua data mentah dari sensor tanpa kompresi',
        'C. Format foto untuk media sosial',
        'D. Format foto hitam putih',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "color temperature" dalam fotografi?',
      options: [
        'A. Suhu fisik kamera saat memotret',
        'B. Karakteristik warna cahaya diukur dalam Kelvin',
        'C. Intensitas warna dalam foto',
        'D. Jumlah warna yang bisa direproduksi kamera',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "tripod" dan kapan digunakan?',
      options: [
        'A. Jenis lensa dengan tiga elemen, digunakan untuk foto makro',
        'B. Penyangga tiga kaki untuk menstabilkan kamera, digunakan untuk eksposur panjang',
        'C. Filter tiga warna untuk foto artistik',
        'D. Teknik memotret dengan tiga kamera',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "focal length" pada lensa?',
      options: [
        'A. Jarak antara kamera dan subjek',
        'B. Jarak antara elemen optik lensa dan sensor, menentukan sudut pandang',
        'C. Panjang fisik lensa',
        'D. Jarak fokus minimum lensa',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Apa yang dimaksud dengan "noise reduction" dalam fotografi?',
      options: [
        'A. Mengurangi suara kamera saat memotret',
        'B. Proses mengurangi bintik-bintik acak (noise) pada foto, terutama dari ISO tinggi',
        'C. Mengurangi getaran kamera',
        'D. Mengurangi distorsi lensa',
      ],
      correctIndex: 1,
    ),
  ];
}

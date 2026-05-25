// lib/core/level_content_data.dart
// TASK-02 — Konten 25 Level (hardcoded)

import '../models/level_model.dart';

/// Semua 25 level konfigurasi — akses via [LevelContentData.levels]
class LevelContentData {
  LevelContentData._();

  static const List<LevelConfig> levels = [
    // ── Level 1: Rule of Thirds ──────────────────────────────────────────
    LevelConfig(
      levelNumber: 1,
      title: 'Rule of Thirds',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Rule of Thirds',
        page1Description:
            'Rule of Thirds adalah teknik komposisi dasar dalam fotografi. '
            'Bayangkan foto dibagi menjadi 9 bagian sama besar oleh 2 garis horizontal '
            'dan 2 garis vertikal. Objek utama ditempatkan di sepanjang garis atau '
            'di titik perpotongannya (titik kuat) agar foto terasa lebih dinamis dan menarik.',
        page1ImagePath: 'assets/images/examples/rule_of_thirds.jpg',
        page2WhenToUse:
            'Gunakan Rule of Thirds saat memotret lanskap, potret, arsitektur, '
            'atau objek apa pun yang ingin kamu buat lebih menarik secara visual. '
            'Hindari menempatkan subjek tepat di tengah kecuali untuk efek simetri.',
        page2HowToUse:
            '1. Aktifkan grid 3×3 di kamera atau smartphone kamu.\n'
            '2. Tempatkan subjek utama di salah satu dari 4 titik perpotongan garis.\n'
            '3. Untuk lanskap, letakkan cakrawala di garis horizontal atas atau bawah.\n'
            '4. Pastikan ruang kosong (negative space) ada di sisi yang berlawanan dari subjek.',
      ),
    ),

    // ── Level 2: Leading Lines ────────────────────────────────────────────
    LevelConfig(
      levelNumber: 2,
      title: 'Leading Lines',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Leading Lines',
        page1Description:
            'Leading Lines adalah garis-garis dalam foto yang mengarahkan pandangan '
            'penonton menuju subjek utama. Garis ini bisa berupa jalan, rel kereta, '
            'pagar, sungai, atau elemen alam lainnya yang membentuk jalur visual.',
        page1ImagePath: 'assets/images/examples/leading_lines.jpg',
        page2WhenToUse:
            'Gunakan Leading Lines saat ada elemen garis alami di sekitar subjek, '
            'seperti jalan panjang, lorong, atau pantai. Sangat efektif untuk foto '
            'arsitektur, lanskap, dan street photography.',
        page2HowToUse:
            '1. Cari garis alami di lingkungan sekitar (jalan, pagar, sungai).\n'
            '2. Posisikan kamera sehingga garis tersebut mengarah ke subjek utama.\n'
            '3. Garis diagonal lebih dinamis dibanding garis lurus horizontal.\n'
            '4. Pastikan garis tidak memotong subjek secara tidak nyaman.',
      ),
    ),

    // ── Level 3: Framing ──────────────────────────────────────────────────
    LevelConfig(
      levelNumber: 3,
      title: 'Framing',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Framing',
        page1Description:
            'Framing adalah teknik menggunakan elemen di sekitar subjek sebagai '
            '"bingkai" alami untuk menarik perhatian ke subjek utama. Bingkai bisa '
            'berupa pintu, jendela, lengkungan, dedaunan, atau terowongan.',
        page1ImagePath: 'assets/images/examples/framing.jpg',
        page2WhenToUse:
            'Gunakan Framing saat ada elemen arsitektur atau alam yang bisa membingkai '
            'subjek. Teknik ini sangat efektif untuk potret, foto perjalanan, dan '
            'foto arsitektur untuk menambah kedalaman visual.',
        page2HowToUse:
            '1. Cari elemen yang bisa menjadi bingkai alami (pintu, jendela, lengkungan).\n'
            '2. Posisikan subjek di dalam area bingkai tersebut.\n'
            '3. Pastikan bingkai tidak terlalu dominan sehingga mengalihkan perhatian.\n'
            '4. Eksperimen dengan fokus: bingkai bisa blur (bokeh) atau tajam.',
      ),
    ),

    // ── Level 4: Symmetry & Patterns ─────────────────────────────────────
    LevelConfig(
      levelNumber: 4,
      title: 'Symmetry & Patterns',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Symmetry & Patterns',
        page1Description:
            'Symmetry adalah keseimbangan visual di mana satu sisi foto mencerminkan '
            'sisi lainnya. Patterns adalah pengulangan elemen visual (bentuk, warna, '
            'tekstur) yang menciptakan ritme dan harmoni dalam foto.',
        page1ImagePath: 'assets/images/examples/symmetry_patterns.jpg',
        page2WhenToUse:
            'Gunakan Symmetry untuk foto arsitektur, refleksi di air, atau wajah. '
            'Gunakan Patterns untuk tekstur alam, bangunan, atau objek berulang. '
            'Memecah pola (pattern break) dengan satu elemen berbeda bisa sangat menarik.',
        page2HowToUse:
            '1. Untuk simetri, temukan sumbu tengah dan posisikan kamera tepat di depannya.\n'
            '2. Gunakan tripod untuk simetri sempurna.\n'
            '3. Untuk pola, isi seluruh frame dengan elemen berulang.\n'
            '4. Coba tambahkan satu elemen berbeda untuk memecah pola dan menciptakan focal point.',
      ),
    ),

    // ── Level 5: Depth of Field ───────────────────────────────────────────
    LevelConfig(
      levelNumber: 5,
      title: 'Depth of Field',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Depth of Field',
        page1Description:
            'Depth of Field (DoF) adalah rentang jarak dalam foto yang tampak tajam. '
            'DoF dangkal (shallow) membuat latar belakang blur (bokeh) sehingga subjek '
            'menonjol. DoF dalam membuat seluruh foto tampak tajam dari depan ke belakang.',
        page1ImagePath: 'assets/images/examples/depth_of_field.jpg',
        page2WhenToUse:
            'DoF dangkal: potret, foto produk, foto bunga/makro — untuk isolasi subjek. '
            'DoF dalam: lanskap, arsitektur, foto grup — saat semua elemen penting.',
        page2HowToUse:
            '1. DoF dangkal: gunakan aperture besar (f/1.8–f/2.8), dekat ke subjek, '
            'latar belakang jauh.\n'
            '2. DoF dalam: gunakan aperture kecil (f/8–f/16).\n'
            '3. Di smartphone: gunakan mode Portrait untuk efek bokeh.\n'
            '4. Jarak antara subjek dan latar belakang sangat mempengaruhi bokeh.',
      ),
    ),

    // ── Level 6: Negative Space ───────────────────────────────────────────
    LevelConfig(
      levelNumber: 6,
      title: 'Negative Space',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Negative Space',
        page1Description:
            'Negative Space adalah area kosong di sekitar subjek utama dalam foto. '
            'Ruang kosong ini bukan "pemborosan" — justru memberikan subjek ruang '
            'untuk "bernapas" dan menciptakan keseimbangan visual yang elegan.',
        page1ImagePath: 'assets/images/examples/negative_space.jpg',
        page2WhenToUse:
            'Gunakan Negative Space untuk foto minimalis, potret artistik, foto produk, '
            'atau saat ingin menyampaikan perasaan kesepian, kebebasan, atau ketenangan. '
            'Sangat efektif dengan latar belakang polos (langit, dinding, air).',
        page2HowToUse:
            '1. Pilih latar belakang yang bersih dan tidak ramai.\n'
            '2. Tempatkan subjek di salah satu sisi frame, biarkan sisi lain kosong.\n'
            '3. Kombinasikan dengan Rule of Thirds untuk penempatan yang optimal.\n'
            '4. Pastikan negative space tidak terlalu ramai sehingga mengalihkan perhatian.',
      ),
    ),

    // ── Level 7: Golden Hour ──────────────────────────────────────────────
    LevelConfig(
      levelNumber: 7,
      title: 'Golden Hour',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Golden Hour',
        page1Description:
            'Golden Hour adalah periode sekitar 1 jam setelah matahari terbit dan '
            '1 jam sebelum matahari terbenam. Cahaya pada waktu ini berwarna hangat '
            '(kuning-oranye-merah), lembut, dan datang dari sudut rendah sehingga '
            'menciptakan bayangan panjang yang dramatis.',
        page1ImagePath: 'assets/images/examples/golden_hour.jpg',
        page2WhenToUse:
            'Gunakan Golden Hour untuk foto lanskap, potret outdoor, foto arsitektur, '
            'dan foto alam. Cahaya hangat membuat kulit tampak lebih indah dan '
            'lanskap terlihat lebih dramatis.',
        page2HowToUse:
            '1. Rencanakan sesi foto 30 menit sebelum golden hour dimulai.\n'
            '2. Gunakan aplikasi cuaca atau "Golden Hour" untuk mengetahui waktu tepat.\n'
            '3. Posisikan subjek menghadap atau menyamping sumber cahaya.\n'
            '4. Eksperimen dengan backlight (cahaya dari belakang) untuk efek siluet atau rim light.',
      ),
    ),

    // ── Level 8: Perspective & Angle ─────────────────────────────────────
    LevelConfig(
      levelNumber: 8,
      title: 'Perspective & Angle',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Perspective & Angle',
        page1Description:
            'Perspective adalah sudut pandang kamera terhadap subjek. Mengubah sudut '
            'pengambilan foto dapat mengubah kesan dan cerita yang disampaikan secara '
            'drastis. Sudut rendah membuat subjek terlihat besar/kuat, sudut tinggi '
            'membuat subjek terlihat kecil/rentan.',
        page1ImagePath: 'assets/images/examples/perspective_angle.jpg',
        page2WhenToUse:
            'Gunakan sudut rendah (low angle) untuk foto arsitektur, potret yang '
            'berwibawa, atau foto alam. Gunakan sudut tinggi (bird\'s eye) untuk '
            'foto makanan, peta, atau untuk menunjukkan skala. Eye level untuk '
            'potret natural dan koneksi emosional.',
        page2HowToUse:
            '1. Low angle: jongkok atau berbaring, arahkan kamera ke atas.\n'
            '2. High angle: berdiri di atas kursi/tangga, arahkan kamera ke bawah.\n'
            '3. Bird\'s eye: foto dari langsung di atas subjek (flat lay).\n'
            '4. Worm\'s eye: foto dari bawah ke atas untuk efek dramatis maksimal.',
      ),
    ),

    // ── Level 9: Reflection / Mirror ─────────────────────────────────────
    LevelConfig(
      levelNumber: 9,
      title: 'Reflection / Mirror',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Reflection / Mirror',
        page1Description:
            'Reflection Photography memanfaatkan pantulan objek di permukaan reflektif '
            'seperti air, kaca, cermin, atau permukaan mengkilap. Teknik ini menciptakan '
            'komposisi simetris yang memukau dan menambah dimensi artistik pada foto.',
        page1ImagePath: 'assets/images/examples/reflection_mirror.jpg',
        page2WhenToUse:
            'Gunakan teknik refleksi di danau/genangan air setelah hujan, jendela kaca '
            'gedung, cermin, atau permukaan mengkilap lainnya. Sangat efektif untuk '
            'foto lanskap, arsitektur, dan foto artistik.',
        page2HowToUse:
            '1. Cari permukaan reflektif yang tenang (air tidak bergelombang).\n'
            '2. Posisikan kamera serendah mungkin untuk mendapatkan refleksi maksimal.\n'
            '3. Gunakan garis cakrawala sebagai pembagi antara objek dan refleksinya.\n'
            '4. Eksperimen dengan menempatkan garis pembagi di tengah atau off-center.',
      ),
    ),

    // ── Level 10: Quiz Evaluasi — Triangle Exposure I ─────────────────────
    LevelConfig(
      levelNumber: 10,
      title: 'Quiz: Triangle Exposure I',
      type: LevelType.quiz,
      passingScore: 70,
      questions: [
        QuizQuestion(
          question: 'Apa yang dimaksud dengan Segitiga Eksposur dalam fotografi?',
          options: [
            'A. Kombinasi ISO, Aperture, dan Shutter Speed',
            'B. Kombinasi Warna, Kontras, dan Saturasi',
            'C. Kombinasi Fokus, Zoom, dan Flash',
            'D. Kombinasi White Balance, Exposure, dan HDR',
          ],
          correctIndex: 0,
        ),
        QuizQuestion(
          question: 'Aperture f/1.8 dibandingkan f/16, mana yang menghasilkan lebih banyak cahaya?',
          options: [
            'A. f/16 karena angkanya lebih besar',
            'B. f/1.8 karena bukaannya lebih lebar',
            'C. Keduanya sama',
            'D. Tergantung kondisi cahaya',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Shutter speed 1/1000s dibandingkan 1/30s, efek apa yang dihasilkan?',
          options: [
            'A. 1/1000s menghasilkan foto lebih terang',
            'B. 1/30s membekukan gerakan lebih baik',
            'C. 1/1000s membekukan gerakan lebih baik',
            'D. Keduanya menghasilkan efek yang sama',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'ISO 3200 dibandingkan ISO 100, apa perbedaan utamanya?',
          options: [
            'A. ISO 3200 lebih gelap dan lebih bersih',
            'B. ISO 3200 lebih terang tetapi lebih banyak noise',
            'C. ISO 100 lebih terang dan lebih banyak noise',
            'D. Tidak ada perbedaan signifikan',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk memotret bintang di malam hari, pengaturan mana yang paling tepat?',
          options: [
            'A. ISO rendah, shutter speed cepat, aperture kecil',
            'B. ISO tinggi, shutter speed lambat, aperture lebar',
            'C. ISO sedang, shutter speed sedang, aperture sedang',
            'D. ISO rendah, shutter speed lambat, aperture kecil',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang terjadi jika foto terlalu terang (overexposed)?',
          options: [
            'A. Detail di area gelap hilang',
            'B. Detail di area terang hilang (blown out)',
            'C. Foto menjadi blur',
            'D. Warna menjadi lebih jenuh',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Depth of Field yang dangkal (shallow DoF) dihasilkan oleh...',
          options: [
            'A. Aperture kecil (f/16) dan subjek jauh',
            'B. Aperture besar (f/1.8) dan subjek dekat',
            'C. ISO tinggi dan shutter speed cepat',
            'D. Shutter speed lambat dan ISO rendah',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Foto air terjun dengan efek sutra (silky water) menggunakan...',
          options: [
            'A. Shutter speed sangat cepat (1/2000s)',
            'B. ISO sangat tinggi (ISO 6400)',
            'C. Shutter speed lambat (1/4s atau lebih lambat)',
            'D. Aperture sangat kecil (f/22)',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'Apa fungsi utama dari histogram dalam fotografi?',
          options: [
            'A. Menunjukkan komposisi foto',
            'B. Menunjukkan distribusi kecerahan/eksposur foto',
            'C. Menunjukkan fokus foto',
            'D. Menunjukkan white balance foto',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Dalam kondisi cahaya redup, urutan penyesuaian yang benar adalah...',
          options: [
            'A. Naikkan ISO dulu, lalu perlambat shutter, lalu buka aperture',
            'B. Buka aperture dulu, lalu perlambat shutter, lalu naikkan ISO',
            'C. Perlambat shutter dulu, lalu buka aperture, lalu naikkan ISO',
            'D. Semua disesuaikan secara bersamaan',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "exposure compensation" (+/- EV)?',
          options: [
            'A. Mengubah warna foto secara keseluruhan',
            'B. Menyesuaikan kecerahan foto dari pengukuran otomatis kamera',
            'C. Mengubah fokus foto',
            'D. Mengubah white balance foto',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Foto olahraga yang membutuhkan pembekuan gerakan cepat memerlukan...',
          options: [
            'A. Shutter speed lambat dan ISO rendah',
            'B. Shutter speed cepat (1/500s atau lebih) dan ISO yang cukup',
            'C. Aperture sangat kecil dan shutter speed sedang',
            'D. ISO sangat rendah dan aperture lebar',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "reciprocal rule" dalam menentukan shutter speed minimum?',
          options: [
            'A. Shutter speed minimum = 1/focal length lensa',
            'B. Shutter speed minimum = focal length × 2',
            'C. Shutter speed minimum selalu 1/60s',
            'D. Shutter speed minimum = ISO / 100',
          ],
          correctIndex: 0,
        ),
        QuizQuestion(
          question: 'Aperture mana yang menghasilkan Depth of Field paling dalam?',
          options: [
            'A. f/1.4',
            'B. f/2.8',
            'C. f/8',
            'D. f/22',
          ],
          correctIndex: 3,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "noise" dalam fotografi digital?',
          options: [
            'A. Suara yang dihasilkan kamera saat memotret',
            'B. Bintik-bintik acak yang mengurangi kualitas foto, biasanya dari ISO tinggi',
            'C. Blur yang disebabkan gerakan kamera',
            'D. Distorsi warna dari white balance yang salah',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Mode "Aperture Priority" (Av/A) pada kamera berarti...',
          options: [
            'A. Kamera mengatur semua pengaturan secara otomatis',
            'B. Fotografer mengatur aperture, kamera mengatur shutter speed',
            'C. Fotografer mengatur shutter speed, kamera mengatur aperture',
            'D. Fotografer mengatur semua pengaturan secara manual',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto potret dengan bokeh indah, pengaturan terbaik adalah...',
          options: [
            'A. f/16, ISO 100, shutter speed 1/60s',
            'B. f/1.8, ISO 200, shutter speed 1/200s',
            'C. f/8, ISO 800, shutter speed 1/30s',
            'D. f/22, ISO 3200, shutter speed 1/1000s',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang terjadi pada foto jika shutter speed terlalu lambat saat memotret handheld?',
          options: [
            'A. Foto menjadi terlalu gelap',
            'B. Foto menjadi terlalu terang',
            'C. Foto menjadi blur karena guncangan kamera',
            'D. Foto kehilangan warna',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'ISO native pada kebanyakan kamera modern biasanya berada di...',
          options: [
            'A. ISO 50',
            'B. ISO 100 atau ISO 200',
            'C. ISO 800',
            'D. ISO 3200',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Dalam kondisi cahaya terang di luar ruangan, pengaturan yang tepat untuk foto tajam adalah...',
          options: [
            'A. ISO 3200, f/1.4, 1/30s',
            'B. ISO 100, f/8, 1/250s',
            'C. ISO 1600, f/16, 1/1000s',
            'D. ISO 800, f/2.8, 1/60s',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa perbedaan antara metering "spot" dan "evaluative/matrix"?',
          options: [
            'A. Spot mengukur seluruh frame, evaluative hanya titik kecil',
            'B. Spot mengukur titik kecil di tengah, evaluative mengukur seluruh frame',
            'C. Keduanya mengukur hal yang sama',
            'D. Spot untuk foto malam, evaluative untuk foto siang',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto long exposure (jejak cahaya mobil di malam hari), diperlukan...',
          options: [
            'A. Shutter speed cepat dan ISO tinggi',
            'B. Tripod, shutter speed lambat (beberapa detik), dan ISO rendah',
            'C. Handheld, shutter speed sedang, dan flash',
            'D. Aperture sangat kecil dan ISO sangat tinggi',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "diffraction" dalam fotografi?',
          options: [
            'A. Efek blur dari gerakan subjek',
            'B. Penurunan ketajaman foto saat menggunakan aperture sangat kecil',
            'C. Distorsi lensa pada aperture lebar',
            'D. Efek cahaya yang masuk dari samping lensa',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Foto siluet yang baik memerlukan...',
          options: [
            'A. Subjek lebih terang dari latar belakang',
            'B. Latar belakang lebih terang dari subjek',
            'C. Subjek dan latar belakang sama terangnya',
            'D. Flash yang kuat untuk menerangi subjek',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa fungsi dari "bracketing" dalam fotografi?',
          options: [
            'A. Memotret beberapa frame dengan eksposur berbeda untuk memilih yang terbaik',
            'B. Memotret dengan flash secara berurutan',
            'C. Mengunci fokus pada subjek bergerak',
            'D. Mengatur white balance secara otomatis',
          ],
          correctIndex: 0,
        ),
      ],
    ),

    // ── Level 11: Golden Ratio ────────────────────────────────────────────
    LevelConfig(
      levelNumber: 11,
      title: 'Golden Ratio',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Golden Ratio',
        page1Description:
            'Golden Ratio (Rasio Emas) adalah proporsi matematika ≈1:1.618 yang '
            'ditemukan di alam dan seni. Dalam fotografi, direpresentasikan sebagai '
            'spiral Fibonacci yang mengarahkan mata penonton secara alami ke titik '
            'fokus utama foto.',
        page1ImagePath: 'assets/images/examples/golden_ratio.jpg',
        page2WhenToUse:
            'Gunakan Golden Ratio untuk komposisi yang lebih organik dan alami '
            'dibanding Rule of Thirds. Sangat efektif untuk foto alam, potret, '
            'dan foto arsitektur yang ingin terasa harmonis.',
        page2HowToUse:
            '1. Bayangkan spiral Fibonacci di atas foto kamu.\n'
            '2. Tempatkan subjek utama di pusat spiral (titik terkecil).\n'
            '3. Biarkan elemen pendukung mengikuti alur spiral.\n'
            '4. Beberapa kamera memiliki overlay Golden Ratio — aktifkan di pengaturan.',
      ),
    ),

    // ── Level 12: Color Theory ────────────────────────────────────────────
    LevelConfig(
      levelNumber: 12,
      title: 'Color Theory',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Color Theory',
        page1Description:
            'Color Theory dalam fotografi adalah pemahaman tentang bagaimana warna '
            'berinteraksi dan mempengaruhi emosi penonton. Warna komplementer (berlawanan '
            'di color wheel) menciptakan kontras kuat, warna analogus (berdekatan) '
            'menciptakan harmoni.',
        page1ImagePath: 'assets/images/examples/color_theory.jpg',
        page2WhenToUse:
            'Gunakan Color Theory saat memilih pakaian untuk sesi foto, memilih latar '
            'belakang, atau saat editing. Warna hangat (merah, oranye, kuning) '
            'menciptakan energi; warna dingin (biru, hijau, ungu) menciptakan ketenangan.',
        page2HowToUse:
            '1. Pelajari color wheel dan identifikasi warna komplementer.\n'
            '2. Cari kombinasi warna yang menarik di lingkungan sekitar.\n'
            '3. Gunakan warna dominan satu dan aksen warna komplementer.\n'
            '4. Saat editing, gunakan color grading untuk memperkuat mood foto.',
      ),
    ),

    // ── Level 13: Texture & Detail ────────────────────────────────────────
    LevelConfig(
      levelNumber: 13,
      title: 'Texture & Detail',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Texture & Detail',
        page1Description:
            'Texture Photography berfokus pada permukaan dan detail halus suatu objek '
            'yang menciptakan kesan taktil — seolah penonton bisa merasakan teksturnya. '
            'Cahaya menyamping (side lighting) sangat efektif untuk menonjolkan tekstur.',
        page1ImagePath: 'assets/images/examples/texture_detail.jpg',
        page2WhenToUse:
            'Gunakan teknik ini untuk foto makro, foto alam (kulit pohon, batu, pasir), '
            'foto makanan, atau foto arsitektur. Sangat efektif saat cahaya datang '
            'dari samping dengan sudut rendah.',
        page2HowToUse:
            '1. Gunakan cahaya menyamping (side light) untuk menciptakan bayangan yang menonjolkan tekstur.\n'
            '2. Dekati subjek sedekat mungkin (gunakan mode macro).\n'
            '3. Gunakan aperture sedang (f/5.6–f/8) untuk ketajaman yang cukup.\n'
            '4. Pastikan kamera stabil — gunakan tripod untuk foto makro.',
      ),
    ),

    // ── Level 14: Fill the Frame ──────────────────────────────────────────
    LevelConfig(
      levelNumber: 14,
      title: 'Fill the Frame',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Fill the Frame',
        page1Description:
            'Fill the Frame adalah teknik mengisi seluruh frame foto dengan subjek '
            'utama, menghilangkan elemen yang tidak perlu. Teknik ini menciptakan '
            'foto yang kuat, intim, dan penuh detail tanpa distraksi.',
        page1ImagePath: 'assets/images/examples/fill_the_frame.jpg',
        page2WhenToUse:
            'Gunakan Fill the Frame untuk potret close-up, foto bunga/tanaman, '
            'foto tekstur, atau saat ingin menunjukkan detail yang tidak terlihat '
            'dari jarak jauh. Sangat efektif untuk foto produk dan editorial.',
        page2HowToUse:
            '1. Dekati subjek secara fisik atau gunakan zoom.\n'
            '2. Pastikan subjek mengisi minimal 80% frame.\n'
            '3. Tidak apa-apa jika tepi subjek sedikit terpotong — ini bisa menambah kesan intim.\n'
            '4. Fokus pada bagian paling menarik dari subjek (mata untuk potret, inti bunga untuk flora).',
      ),
    ),

    // ── Level 15: Quiz Evaluasi — Lighting I ─────────────────────────────
    LevelConfig(
      levelNumber: 15,
      title: 'Quiz: Lighting I',
      type: LevelType.quiz,
      passingScore: 70,
      questions: [
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "Golden Hour" dalam fotografi?',
          options: [
            'A. Jam 12 siang saat matahari paling terang',
            'B. Sekitar 1 jam setelah matahari terbit dan sebelum terbenam',
            'C. Saat menggunakan filter kuning pada lensa',
            'D. Waktu terbaik untuk foto indoor',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Cahaya "hard light" menghasilkan...',
          options: [
            'A. Bayangan lembut dan gradasi halus',
            'B. Bayangan tajam dan kontras tinggi',
            'C. Tidak ada bayangan sama sekali',
            'D. Warna yang lebih hangat',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa fungsi dari diffuser pada flash/lampu studio?',
          options: [
            'A. Meningkatkan intensitas cahaya',
            'B. Mengubah warna cahaya menjadi lebih hangat',
            'C. Melembutkan cahaya dan mengurangi bayangan keras',
            'D. Memfokuskan cahaya ke satu titik',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'Foto siluet yang baik memerlukan kondisi pencahayaan...',
          options: [
            'A. Cahaya dari depan subjek (front lighting)',
            'B. Cahaya dari belakang subjek (backlight) yang lebih terang',
            'C. Cahaya dari samping subjek (side lighting)',
            'D. Tidak ada cahaya sama sekali',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'White Balance "Cloudy" (berawan) menghasilkan warna...',
          options: [
            'A. Lebih dingin/kebiruan',
            'B. Lebih hangat/kekuningan',
            'C. Lebih hijau',
            'D. Tidak mengubah warna',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Teknik "Rembrandt lighting" dalam potret ditandai dengan...',
          options: [
            'A. Cahaya merata dari dua sisi',
            'B. Segitiga cahaya kecil di pipi yang lebih gelap',
            'C. Cahaya dari bawah wajah',
            'D. Cahaya dari langsung di atas kepala',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "catchlight" dalam foto potret?',
          options: [
            'A. Cahaya yang menangkap gerakan subjek',
            'B. Pantulan cahaya kecil di mata subjek',
            'C. Cahaya yang digunakan untuk foto olahraga',
            'D. Filter untuk menangkap cahaya matahari',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto produk dengan latar putih bersih, teknik pencahayaan yang digunakan adalah...',
          options: [
            'A. Satu lampu dari samping',
            'B. High-key lighting dengan beberapa sumber cahaya',
            'C. Low-key lighting dengan satu lampu',
            'D. Cahaya alami dari jendela saja',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "blue hour" dalam fotografi?',
          options: [
            'A. Waktu saat langit berwarna biru cerah di siang hari',
            'B. Periode singkat setelah matahari terbenam saat langit berwarna biru dalam',
            'C. Saat menggunakan filter biru pada lensa',
            'D. Waktu terbaik untuk foto bawah air',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Cahaya dari jendela (window light) paling efektif untuk...',
          options: [
            'A. Foto landscape outdoor',
            'B. Foto potret indoor yang natural dan lembut',
            'C. Foto olahraga indoor',
            'D. Foto makro detail kecil',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "fill light" dalam setup pencahayaan studio?',
          options: [
            'A. Lampu utama yang menerangi subjek',
            'B. Lampu yang mengisi bayangan dari main light',
            'C. Lampu latar untuk memisahkan subjek dari background',
            'D. Lampu yang menerangi rambut subjek',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk mengurangi bayangan keras di wajah saat foto outdoor di siang hari, solusinya adalah...',
          options: [
            'A. Gunakan ISO lebih tinggi',
            'B. Gunakan fill flash atau reflektor',
            'C. Gunakan aperture lebih kecil',
            'D. Gunakan shutter speed lebih cepat',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "light ratio" dalam fotografi potret?',
          options: [
            'A. Perbandingan antara focal length dan aperture',
            'B. Perbandingan kecerahan antara sisi terang dan gelap wajah',
            'C. Perbandingan antara ISO dan shutter speed',
            'D. Perbandingan antara ukuran sensor dan lensa',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Teknik "butterfly lighting" dalam potret menghasilkan...',
          options: [
            'A. Bayangan berbentuk kupu-kupu di latar belakang',
            'B. Bayangan kecil berbentuk kupu-kupu di bawah hidung',
            'C. Cahaya yang menyebar seperti sayap kupu-kupu',
            'D. Efek bokeh berbentuk kupu-kupu',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto arsitektur interior, sumber cahaya terbaik adalah...',
          options: [
            'A. Flash langsung dari kamera',
            'B. Cahaya alami dari jendela dikombinasikan dengan ambient light',
            'C. Lampu flash eksternal yang sangat kuat',
            'D. Tidak menggunakan cahaya tambahan sama sekali',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "color temperature" dalam fotografi?',
          options: [
            'A. Suhu fisik lampu dalam derajat Celsius',
            'B. Karakteristik warna cahaya diukur dalam Kelvin (K)',
            'C. Intensitas cahaya dalam lumen',
            'D. Kecepatan cahaya dalam medium tertentu',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Cahaya dengan color temperature 3200K terlihat...',
          options: [
            'A. Sangat biru/dingin',
            'B. Netral/putih',
            'C. Hangat/kekuningan-oranye',
            'D. Kehijauan',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'Teknik "bounce flash" berarti...',
          options: [
            'A. Flash yang bergerak mengikuti subjek',
            'B. Memantulkan cahaya flash ke langit-langit atau dinding',
            'C. Menggunakan dua flash secara bersamaan',
            'D. Flash yang menyala berulang kali',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto makanan yang menarik, pencahayaan yang paling umum digunakan adalah...',
          options: [
            'A. Flash langsung dari atas',
            'B. Cahaya alami dari samping (side light) atau belakang (backlight)',
            'C. Lampu neon dari atas',
            'D. Flash dari bawah makanan',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "high-key photography"?',
          options: [
            'A. Foto dengan banyak area gelap dan kontras tinggi',
            'B. Foto dengan dominasi area terang dan sedikit bayangan',
            'C. Foto yang diambil dari sudut tinggi',
            'D. Foto dengan ISO sangat tinggi',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "low-key photography"?',
          options: [
            'A. Foto dengan dominasi area gelap dan kontras dramatis',
            'B. Foto yang diambil dari sudut rendah',
            'C. Foto dengan ISO sangat rendah',
            'D. Foto dengan banyak area terang',
          ],
          correctIndex: 0,
        ),
        QuizQuestion(
          question: 'Untuk menghindari "red eye" dalam foto flash, solusinya adalah...',
          options: [
            'A. Gunakan ISO lebih tinggi',
            'B. Gunakan flash off-camera atau aktifkan red-eye reduction',
            'C. Gunakan aperture lebih kecil',
            'D. Gunakan shutter speed lebih cepat',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "ambient light" dalam fotografi?',
          options: [
            'A. Cahaya dari flash kamera',
            'B. Cahaya alami atau buatan yang sudah ada di lokasi',
            'C. Cahaya dari lampu studio',
            'D. Cahaya yang dipantulkan dari reflektor',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Teknik "chiaroscuro" dalam fotografi mengacu pada...',
          options: [
            'A. Teknik komposisi menggunakan garis diagonal',
            'B. Kontras dramatis antara area terang dan gelap',
            'C. Teknik penggunaan warna komplementer',
            'D. Teknik memotret dengan cahaya merata',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto potret outdoor di bawah sinar matahari langsung, posisi terbaik subjek adalah...',
          options: [
            'A. Menghadap langsung ke matahari',
            'B. Membelakangi matahari dengan fill flash atau reflektor di depan',
            'C. Di bawah bayangan pohon tanpa cahaya tambahan',
            'D. Di dalam ruangan dengan cahaya buatan',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ── Level 16: Silhouette ──────────────────────────────────────────────
    LevelConfig(
      levelNumber: 16,
      title: 'Silhouette',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Silhouette',
        page1Description:
            'Silhouette Photography adalah teknik memotret subjek sebagai bentuk gelap '
            'solid di depan latar belakang yang terang. Teknik ini menciptakan foto '
            'yang dramatis, misterius, dan penuh emosi dengan mengandalkan bentuk '
            'dan kontur subjek.',
        page1ImagePath: 'assets/images/examples/silhouette.jpg',
        page2WhenToUse:
            'Gunakan teknik siluet saat ada sumber cahaya kuat di belakang subjek: '
            'matahari terbenam/terbit, jendela terang, atau lampu latar. Sangat '
            'efektif untuk foto manusia, pohon, bangunan, dan hewan.',
        page2HowToUse:
            '1. Posisikan subjek di depan sumber cahaya yang terang.\n'
            '2. Ukur eksposur pada area terang (langit/latar), bukan pada subjek.\n'
            '3. Pastikan bentuk subjek mudah dikenali dari konturnya saja.\n'
            '4. Gunakan mode manual atau spot metering untuk kontrol penuh.',
      ),
    ),

    // ── Level 17: Motion Blur ─────────────────────────────────────────────
    LevelConfig(
      levelNumber: 17,
      title: 'Motion Blur',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Motion Blur',
        page1Description:
            'Motion Blur adalah efek blur yang terjadi saat subjek atau kamera bergerak '
            'selama eksposur. Efek ini bisa digunakan secara kreatif untuk menunjukkan '
            'kecepatan, energi, dan dinamisme dalam foto.',
        page1ImagePath: 'assets/images/examples/motion_blur.jpg',
        page2WhenToUse:
            'Gunakan Motion Blur untuk foto air terjun (efek sutra), lalu lintas malam '
            '(light trails), olahraga, atau tarian. Teknik "panning" mengikuti subjek '
            'bergerak menghasilkan subjek tajam dengan latar blur.',
        page2HowToUse:
            '1. Gunakan shutter speed lambat (1/15s – beberapa detik tergantung kecepatan subjek).\n'
            '2. Gunakan tripod untuk menjaga kamera stabil (kecuali untuk panning).\n'
            '3. Untuk panning: ikuti gerakan subjek dengan kamera saat menekan shutter.\n'
            '4. Eksperimen dengan berbagai shutter speed untuk efek yang berbeda.',
      ),
    ),

    // ── Level 18: Bokeh ───────────────────────────────────────────────────
    LevelConfig(
      levelNumber: 18,
      title: 'Bokeh',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Bokeh',
        page1Description:
            'Bokeh (dari bahasa Jepang "boke" = blur) adalah kualitas estetika dari '
            'area blur di luar fokus dalam foto. Bokeh yang indah tampak sebagai '
            'lingkaran cahaya lembut yang memisahkan subjek dari latar belakang '
            'secara visual.',
        page1ImagePath: 'assets/images/examples/bokeh.jpg',
        page2WhenToUse:
            'Gunakan Bokeh untuk foto potret, foto produk, foto bunga, atau situasi '
            'apa pun di mana kamu ingin mengisolasi subjek dari latar belakang yang '
            'ramai. Sangat populer untuk foto pernikahan dan fashion.',
        page2HowToUse:
            '1. Gunakan lensa dengan aperture lebar (f/1.4 – f/2.8).\n'
            '2. Dekatkan kamera ke subjek.\n'
            '3. Jauhkan subjek dari latar belakang (semakin jauh, semakin blur).\n'
            '4. Latar belakang dengan titik cahaya (lampu, daun dengan cahaya) menghasilkan bokeh paling indah.',
      ),
    ),

    // ── Level 19: Color Contrast ──────────────────────────────────────────
    LevelConfig(
      levelNumber: 19,
      title: 'Color Contrast',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Color Contrast',
        page1Description:
            'Color Contrast adalah penggunaan warna-warna yang saling berlawanan '
            'atau sangat berbeda untuk menciptakan foto yang mencolok dan berenergi. '
            'Warna komplementer (berlawanan di color wheel) seperti biru-oranye, '
            'merah-hijau, atau kuning-ungu menciptakan kontras paling kuat.',
        page1ImagePath: 'assets/images/examples/color_contrast.jpg',
        page2WhenToUse:
            'Gunakan Color Contrast untuk foto street photography, foto fashion, '
            'foto alam, atau saat ingin membuat foto yang langsung menarik perhatian. '
            'Sangat efektif untuk foto produk dan iklan.',
        page2HowToUse:
            '1. Cari kombinasi warna komplementer di lingkungan sekitar.\n'
            '2. Pastikan satu warna dominan dan warna lain sebagai aksen.\n'
            '3. Gunakan pakaian atau properti berwarna kontras dengan latar belakang.\n'
            '4. Saat editing, tingkatkan saturasi warna utama untuk kontras lebih kuat.',
      ),
    ),

    // ── Level 20: Quiz Evaluasi — Triangle Exposure II ────────────────────
    LevelConfig(
      levelNumber: 20,
      title: 'Quiz: Triangle Exposure II',
      type: LevelType.quiz,
      passingScore: 70,
      questions: [
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "dynamic range" dalam fotografi?',
          options: [
            'A. Rentang gerakan yang bisa dibekukan kamera',
            'B. Rentang kecerahan dari gelap ke terang yang bisa direkam sensor',
            'C. Rentang focal length dari lensa zoom',
            'D. Rentang ISO yang tersedia di kamera',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Teknik HDR (High Dynamic Range) digunakan untuk...',
          options: [
            'A. Meningkatkan resolusi foto',
            'B. Menggabungkan beberapa eksposur untuk menangkap detail di area terang dan gelap',
            'C. Membuat foto hitam putih',
            'D. Meningkatkan kecepatan autofokus',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "expose to the right" (ETTR)?',
          options: [
            'A. Memotret dari sisi kanan subjek',
            'B. Membuat eksposur sedikit lebih terang untuk meminimalkan noise',
            'C. Menggunakan komposisi dengan subjek di kanan frame',
            'D. Mengatur white balance ke arah warna hangat',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Format RAW dibandingkan JPEG, apa keunggulan utama RAW?',
          options: [
            'A. Ukuran file lebih kecil',
            'B. Langsung bisa dibagikan ke media sosial',
            'C. Menyimpan lebih banyak data untuk editing yang lebih fleksibel',
            'D. Warna lebih akurat langsung dari kamera',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "clipping" dalam histogram?',
          options: [
            'A. Memotong bagian foto yang tidak diinginkan',
            'B. Hilangnya detail di area paling terang atau paling gelap',
            'C. Efek blur pada tepi foto',
            'D. Distorsi warna pada foto',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto astrofotografi (foto bintang), pengaturan yang tepat adalah...',
          options: [
            'A. ISO 100, f/16, 30 detik',
            'B. ISO 3200-6400, f/2.8 atau lebih lebar, 15-25 detik',
            'C. ISO 800, f/8, 1 menit',
            'D. ISO 200, f/4, 5 menit',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "sunny 16 rule" dalam fotografi?',
          options: [
            'A. Aturan memotret hanya pada jam 16.00',
            'B. Di bawah sinar matahari cerah, gunakan f/16 dengan shutter speed = 1/ISO',
            'C. Menggunakan 16 megapiksel untuk foto outdoor',
            'D. Aturan komposisi dengan 16 titik fokus',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "zone system" dalam fotografi?',
          options: [
            'A. Sistem pembagian area foto menjadi zona fokus',
            'B. Sistem 11 zona kecerahan dari hitam total hingga putih total',
            'C. Sistem pengaturan zona waktu untuk timestamp foto',
            'D. Sistem pembagian frame menjadi zona komposisi',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto makro dengan perbesaran 1:1, tantangan utama adalah...',
          options: [
            'A. Terlalu banyak cahaya masuk',
            'B. Depth of field yang sangat dangkal dan getaran kamera',
            'C. Warna yang tidak akurat',
            'D. Autofokus yang terlalu cepat',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "focus stacking"?',
          options: [
            'A. Mengunci fokus pada satu titik',
            'B. Menggabungkan beberapa foto dengan fokus berbeda untuk DoF lebih dalam',
            'C. Menggunakan beberapa lensa secara bersamaan',
            'D. Teknik autofokus untuk subjek bergerak',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "vignetting" dalam fotografi?',
          options: [
            'A. Efek blur pada seluruh foto',
            'B. Penggelapan di sudut-sudut foto',
            'C. Distorsi lensa pada tepi foto',
            'D. Efek cahaya berlebih di tengah foto',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto landscape dengan foreground dan background sama tajam, teknik yang digunakan adalah...',
          options: [
            'A. Aperture lebar dan fokus di foreground',
            'B. Aperture kecil (f/11-f/16) dan fokus di hyperfocal distance',
            'C. ISO tinggi dan shutter speed cepat',
            'D. Menggunakan lensa wide angle dengan aperture lebar',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "hyperfocal distance"?',
          options: [
            'A. Jarak maksimum yang bisa difokus lensa',
            'B. Jarak fokus terdekat yang membuat semua objek dari setengah jarak tersebut hingga tak terhingga tampak tajam',
            'C. Jarak antara kamera dan subjek untuk bokeh terbaik',
            'D. Jarak minimum untuk foto makro',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "chromatic aberration" dalam fotografi?',
          options: [
            'A. Distorsi bentuk pada tepi foto',
            'B. Pinggiran berwarna (biasanya ungu atau hijau) di tepi objek kontras tinggi',
            'C. Noise berwarna pada foto ISO tinggi',
            'D. Efek flare dari sumber cahaya',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto portrait dengan mata tajam dan latar blur, fokus harus ditempatkan di...',
          options: [
            'A. Hidung subjek',
            'B. Mata subjek (terutama mata yang lebih dekat ke kamera)',
            'C. Telinga subjek',
            'D. Dahi subjek',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "back-button focus" (BBF)?',
          options: [
            'A. Tombol di belakang kamera untuk mengatur ISO',
            'B. Memisahkan fungsi autofokus dari tombol shutter ke tombol di belakang kamera',
            'C. Tombol untuk mengakses menu kamera',
            'D. Teknik memotret dari belakang subjek',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "lens flare" dan kapan bisa digunakan secara kreatif?',
          options: [
            'A. Distorsi lensa yang selalu harus dihindari',
            'B. Efek cahaya yang masuk langsung ke lensa, bisa digunakan untuk kesan dramatis/artistik',
            'C. Efek blur pada tepi foto',
            'D. Pantulan cahaya dari sensor kamera',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto dengan cahaya campuran (mixed lighting), tantangan utama adalah...',
          options: [
            'A. Terlalu banyak cahaya',
            'B. White balance yang sulit karena sumber cahaya berbeda color temperature',
            'C. Autofokus yang tidak akurat',
            'D. Depth of field yang terlalu dalam',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "tonal range" dalam foto hitam putih?',
          options: [
            'A. Rentang nada musik dalam video',
            'B. Rentang gradasi dari hitam total hingga putih total dalam foto',
            'C. Jumlah warna yang bisa direproduksi sensor',
            'D. Kualitas suara dalam video',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto dengan efek "light painting", diperlukan...',
          options: [
            'A. Flash yang sangat kuat',
            'B. Ruangan gelap, shutter speed lambat, dan sumber cahaya bergerak',
            'C. ISO sangat tinggi dan aperture kecil',
            'D. Lensa makro dan tripod',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "metering mode" pada kamera?',
          options: [
            'A. Mode untuk mengukur jarak ke subjek',
            'B. Cara kamera mengukur cahaya untuk menentukan eksposur',
            'C. Mode untuk mengukur kecepatan subjek',
            'D. Cara kamera mengukur warna',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "spot metering" dan kapan digunakan?',
          options: [
            'A. Mengukur cahaya seluruh frame, digunakan untuk foto landscape',
            'B. Mengukur cahaya area kecil (1-5%), digunakan saat subjek dan latar sangat berbeda kecerahan',
            'C. Mengukur cahaya area tengah, digunakan untuk semua situasi',
            'D. Mengukur cahaya dari flash, digunakan untuk foto studio',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "freeze action" olahraga di dalam ruangan dengan cahaya redup, pengaturan terbaik adalah...',
          options: [
            'A. ISO 100, f/16, 1/1000s',
            'B. ISO 3200-6400, f/2.8, 1/500s atau lebih cepat',
            'C. ISO 800, f/8, 1/60s',
            'D. ISO 200, f/4, 1/250s',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "exposure latitude"?',
          options: [
            'A. Lokasi geografis terbaik untuk memotret',
            'B. Toleransi kesalahan eksposur yang masih bisa diperbaiki saat editing',
            'C. Rentang focal length lensa',
            'D. Jarak maksimum flash efektif',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "star trails" (jejak bintang), teknik yang digunakan adalah...',
          options: [
            'A. Satu eksposur sangat panjang (beberapa jam) atau banyak eksposur pendek yang digabungkan',
            'B. Flash yang sangat kuat',
            'C. ISO sangat rendah dan aperture kecil',
            'D. Lensa telephoto dengan stabilisasi gambar',
          ],
          correctIndex: 0,
        ),
      ],
    ),

    // ── Level 21: Sense of Scale ──────────────────────────────────────────
    LevelConfig(
      levelNumber: 21,
      title: 'Sense of Scale',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Sense of Scale',
        page1Description:
            'Sense of Scale adalah teknik memasukkan elemen yang ukurannya sudah '
            'dikenal (manusia, mobil, pohon) ke dalam foto untuk memberikan gambaran '
            'nyata tentang ukuran subjek utama. Teknik ini sangat efektif untuk '
            'menunjukkan kebesaran alam atau arsitektur.',
        page1ImagePath: 'assets/images/examples/sense_of_scale.jpg',
        page2WhenToUse:
            'Gunakan Sense of Scale untuk foto lanskap dengan gunung/air terjun besar, '
            'foto arsitektur gedung tinggi, foto gua, atau objek alam yang ingin '
            'ditunjukkan ukuran sebenarnya.',
        page2HowToUse:
            '1. Masukkan manusia atau objek yang ukurannya dikenal ke dalam frame.\n'
            '2. Posisikan elemen skala di area yang tidak mengalihkan perhatian dari subjek utama.\n'
            '3. Pastikan elemen skala cukup kecil dibanding subjek untuk efek maksimal.\n'
            '4. Gunakan wide angle lens untuk menangkap keseluruhan skena.',
      ),
    ),

    // ── Level 22: Minimalism ──────────────────────────────────────────────
    LevelConfig(
      levelNumber: 22,
      title: 'Minimalism',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Minimalism',
        page1Description:
            'Minimalism dalam fotografi adalah filosofi "less is more" — menghilangkan '
            'semua elemen yang tidak perlu dan hanya menyisakan yang esensial. '
            'Foto minimalis biasanya memiliki sedikit elemen, banyak ruang kosong, '
            'dan pesan yang kuat.',
        page1ImagePath: 'assets/images/examples/minimalism.jpg',
        page2WhenToUse:
            'Gunakan Minimalism untuk foto arsitektur, foto alam, foto produk, atau '
            'saat ingin menyampaikan pesan yang kuat dan bersih. Sangat efektif '
            'dengan latar belakang polos atau sederhana.',
        page2HowToUse:
            '1. Cari latar belakang yang bersih dan tidak ramai.\n'
            '2. Pilih satu subjek utama dan hilangkan semua distraksi.\n'
            '3. Gunakan Negative Space secara maksimal.\n'
            '4. Perhatikan garis, bentuk, dan warna — setiap elemen harus punya tujuan.',
      ),
    ),

    // ── Level 23: Environmental Portrait ─────────────────────────────────
    LevelConfig(
      levelNumber: 23,
      title: 'Environmental Portrait',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'Environmental Portrait',
        page1Description:
            'Environmental Portrait adalah foto potret yang menampilkan subjek dalam '
            'lingkungan atau konteks kehidupan mereka sehari-hari. Berbeda dengan '
            'potret studio, foto ini menceritakan siapa subjek melalui lingkungan '
            'di sekitar mereka.',
        page1ImagePath: 'assets/images/examples/environmental_portrait.jpg',
        page2WhenToUse:
            'Gunakan Environmental Portrait untuk foto dokumenter, foto profesi, '
            'foto jurnalistik, atau saat ingin menceritakan kisah seseorang melalui '
            'lingkungan mereka. Sangat efektif untuk foto petani, seniman, pengrajin.',
        page2HowToUse:
            '1. Pilih lokasi yang relevan dengan kehidupan atau pekerjaan subjek.\n'
            '2. Biarkan subjek berinteraksi dengan lingkungannya secara natural.\n'
            '3. Gunakan wide angle untuk menampilkan lebih banyak konteks lingkungan.\n'
            '4. Pastikan ekspresi subjek natural — ajak bicara sebelum memotret.',
      ),
    ),

    // ── Level 24: L-Shape Composition ────────────────────────────────────
    LevelConfig(
      levelNumber: 24,
      title: 'L-Shape Composition',
      type: LevelType.materi,
      materiContent: MateriContent(
        page1Title: 'L-Shape Composition',
        page1Description:
            'L-Shape Composition adalah teknik komposisi di mana elemen-elemen dalam '
            'foto membentuk huruf "L". Bentuk L ini menciptakan kerangka visual yang '
            'kuat, mengarahkan mata penonton, dan memberikan keseimbangan asimetris '
            'yang menarik.',
        page1ImagePath: 'assets/images/examples/l_shape_composition.jpg',
        page2WhenToUse:
            'Gunakan L-Shape Composition untuk foto arsitektur, foto alam dengan '
            'pohon/tebing, foto interior, atau saat ada elemen vertikal dan horizontal '
            'yang bisa membentuk sudut L.',
        page2HowToUse:
            '1. Cari elemen yang membentuk sudut siku-siku (90 derajat) dalam frame.\n'
            '2. Tempatkan elemen L di tepi frame untuk membingkai area kosong di tengah.\n'
            '3. Subjek utama bisa ditempatkan di area kosong yang dibingkai oleh L.\n'
            '4. Eksperimen dengan orientasi L (normal, terbalik, atau diputar).',
      ),
    ),

    // ── Level 25: Quiz Evaluasi — Pencahayaan II (Post Test Trigger) ──────
    LevelConfig(
      levelNumber: 25,
      title: 'Quiz: Pencahayaan II',
      type: LevelType.quiz,
      passingScore: 70,
      questions: [
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "Inverse Square Law" dalam pencahayaan?',
          options: [
            'A. Intensitas cahaya berbanding lurus dengan jarak',
            'B. Intensitas cahaya berkurang sebanding dengan kuadrat jarak dari sumber',
            'C. Intensitas cahaya tidak berubah dengan jarak',
            'D. Intensitas cahaya berlipat ganda setiap meter',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "Ratio Lighting" 3:1 dalam potret?',
          options: [
            'A. Menggunakan 3 lampu dengan 1 reflektor',
            'B. Sisi terang wajah 3 kali lebih terang dari sisi gelap',
            'C. Jarak lampu 3 kali lebih jauh dari subjek',
            'D. Menggunakan 3 warna cahaya berbeda',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Teknik "Clamshell Lighting" dalam fotografi potret menggunakan...',
          options: [
            'A. Satu lampu dari samping',
            'B. Dua lampu: satu di atas dan satu di bawah wajah menghadap ke atas',
            'C. Tiga lampu membentuk segitiga',
            'D. Satu lampu dari belakang subjek',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "specular highlight" dalam fotografi?',
          options: [
            'A. Cahaya yang menyebar merata',
            'B. Pantulan cahaya langsung yang sangat terang pada permukaan mengkilap',
            'C. Cahaya yang melewati diffuser',
            'D. Cahaya ambient yang lembut',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto produk dengan permukaan mengkilap (jam tangan, perhiasan), teknik pencahayaan yang tepat adalah...',
          options: [
            'A. Flash langsung dari kamera',
            'B. Tent lighting atau diffused light dari semua sisi untuk menghindari specular highlight',
            'C. Satu lampu keras dari samping',
            'D. Cahaya alami dari jendela',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa itu "gobo" dalam setup pencahayaan studio?',
          options: [
            'A. Jenis lampu studio yang kuat',
            'B. Panel yang menghalangi atau membentuk cahaya',
            'C. Reflektor berbentuk bulat',
            'D. Diffuser untuk melembutkan cahaya',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "color rendering index" (CRI) pada lampu?',
          options: [
            'A. Kecerahan lampu dalam lumen',
            'B. Kemampuan lampu mereproduksi warna secara akurat dibanding cahaya alami',
            'C. Warna cahaya yang dihasilkan lampu',
            'D. Konsumsi daya lampu',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "high fashion" dengan look dramatis, setup pencahayaan yang umum digunakan adalah...',
          options: [
            'A. Soft box besar dari depan',
            'B. Hard light dari samping dengan sedikit fill',
            'C. Cahaya alami dari jendela',
            'D. Ring flash dari depan',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "practical light" dalam sinematografi/fotografi?',
          options: [
            'A. Lampu studio yang praktis digunakan',
            'B. Sumber cahaya yang terlihat dalam frame (lampu meja, lilin, TV)',
            'C. Lampu yang hemat energi',
            'D. Lampu portabel untuk outdoor',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Teknik "split lighting" dalam potret menghasilkan...',
          options: [
            'A. Cahaya merata di seluruh wajah',
            'B. Tepat setengah wajah terang dan setengah gelap',
            'C. Bayangan kecil di bawah hidung',
            'D. Cahaya dari belakang kepala',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "TTL flash" (Through The Lens)?',
          options: [
            'A. Flash yang melewati lensa kamera',
            'B. Sistem pengukuran flash otomatis menggunakan sensor kamera',
            'C. Flash yang dipasang di depan lensa',
            'D. Flash dengan kabel yang terhubung ke kamera',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "rim lighting" atau "hair light", lampu ditempatkan...',
          options: [
            'A. Di depan subjek',
            'B. Di belakang dan sedikit di samping subjek',
            'C. Di bawah subjek',
            'D. Di atas subjek langsung',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "guide number" pada flash?',
          options: [
            'A. Nomor seri flash',
            'B. Ukuran kekuatan flash (GN = jarak × f-number)',
            'C. Jumlah foto yang bisa diambil dengan satu baterai',
            'D. Waktu recycle flash',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "beauty dish" dalam fotografi potret, karakteristik cahayanya adalah...',
          options: [
            'A. Sangat lembut seperti soft box besar',
            'B. Antara hard dan soft light, dengan catchlight berbentuk donat',
            'C. Sangat keras seperti bare flash',
            'D. Cahaya merata dari semua arah',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "sync speed" pada kamera?',
          options: [
            'A. Kecepatan autofokus kamera',
            'B. Shutter speed maksimum yang bisa digunakan dengan flash tanpa banding hitam',
            'C. Kecepatan transfer foto ke komputer',
            'D. Kecepatan burst shooting kamera',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Teknik "High Speed Sync" (HSS) pada flash memungkinkan...',
          options: [
            'A. Flash menyala lebih cepat',
            'B. Menggunakan flash dengan shutter speed di atas sync speed normal',
            'C. Sinkronisasi beberapa flash sekaligus',
            'D. Flash dengan recycle time lebih cepat',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "contre-jour" (melawan cahaya), teknik yang digunakan adalah...',
          options: [
            'A. Memotret dengan cahaya dari depan',
            'B. Memotret dengan cahaya dari belakang subjek, sering menghasilkan siluet atau rim light',
            'C. Memotret dengan cahaya dari samping',
            'D. Memotret tanpa cahaya tambahan',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "Kelvin" dalam konteks fotografi?',
          options: [
            'A. Satuan kecerahan lampu',
            'B. Satuan pengukuran color temperature cahaya',
            'C. Satuan kekuatan flash',
            'D. Satuan resolusi sensor',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "Orton effect" (dreamy glow), teknik yang digunakan adalah...',
          options: [
            'A. Menggunakan filter UV',
            'B. Menggabungkan foto tajam dengan versi blur untuk efek cahaya lembut',
            'C. Menggunakan flash dengan diffuser',
            'D. Memotret saat golden hour',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "light modifier" dalam fotografi studio?',
          options: [
            'A. Software untuk mengedit pencahayaan foto',
            'B. Aksesori yang mengubah karakteristik cahaya (soft box, beauty dish, grid)',
            'C. Filter kamera untuk mengatur cahaya',
            'D. Pengaturan white balance di kamera',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "Brenizer method" (bokeh panorama), teknik yang digunakan adalah...',
          options: [
            'A. Menggunakan lensa fisheye',
            'B. Menggabungkan banyak foto dengan aperture lebar untuk DoF dangkal di foto lebar',
            'C. Menggunakan filter ND untuk eksposur panjang',
            'D. Memotret dengan flash multiple',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "catchlight" yang ideal dalam foto potret?',
          options: [
            'A. Tidak ada pantulan di mata',
            'B. Satu atau dua pantulan cahaya kecil di mata yang membuat mata terlihat hidup',
            'C. Pantulan besar yang menutupi iris',
            'D. Pantulan di bagian bawah mata',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "Tyndall effect" (berkas cahaya terlihat), kondisi yang diperlukan adalah...',
          options: [
            'A. Cahaya sangat terang tanpa partikel di udara',
            'B. Cahaya melewati partikel di udara (debu, asap, kabut) dari sudut tertentu',
            'C. Cahaya dari bawah permukaan air',
            'D. Cahaya yang dipantulkan dari cermin',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Apa yang dimaksud dengan "Fresnel lens" dalam pencahayaan studio?',
          options: [
            'A. Lensa kamera dengan aperture sangat lebar',
            'B. Lensa yang memfokuskan cahaya menjadi berkas yang bisa diarahkan',
            'C. Filter untuk melembutkan cahaya',
            'D. Lensa makro untuk foto detail',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Untuk foto "Rembrandt lighting" yang sempurna, segitiga cahaya di pipi harus...',
          options: [
            'A. Lebih besar dari mata',
            'B. Tidak lebih besar dari mata dan tidak menyentuh hidung atau mulut',
            'C. Menutupi seluruh pipi',
            'D. Berada di dahi subjek',
          ],
          correctIndex: 1,
        ),
      ],
    ),
  ];

  /// Ambil konfigurasi level berdasarkan nomor level (1-25)
  static LevelConfig? getLevel(int levelNumber) {
    try {
      return levels.firstWhere((l) => l.levelNumber == levelNumber);
    } catch (_) {
      return null;
    }
  }

  /// Daftar nomor level yang merupakan quiz checkpoint
  static const List<int> quizLevels = [10, 15, 20, 25];

  /// Cek apakah level tertentu adalah quiz
  static bool isQuizLevel(int levelNumber) => quizLevels.contains(levelNumber);
}

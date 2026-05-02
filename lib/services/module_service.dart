import '../models/module_model.dart';

class ModuleService {
  Future<List<ModuleModel>> getModules() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      ModuleModel(
        id: 'M01',
        title: 'Rule of Thirds (Aturan Sepertiga)',
        description: 'Letakkan subjek di titik potong garis sepertiga',
        materialContent: 'Teknik yang paling dasar namun sangat ampuh. Bayangkan bidang foto dibagi menjadi 9 kotak dengan 2 garis horizontal dan 2 garis vertikal. Letakkan subjek utama di titik potong atau di sepanjang garis tersebut agar foto terlihat lebih seimbang dan natural.',
        order: 1,
      ),
      ModuleModel(
        id: 'M02',
        title: 'Leading Lines (Garis Penuntun)',
        description: 'Gunakan garis untuk mengarahkan mata ke subjek',
        materialContent: 'Gunakan garis-garis yang ada di sekitar (seperti jalan, pagar, jembatan, atau bayangan) untuk mengarahkan mata penonton menuju subjek utama. Ini memberikan efek kedalaman (depth) yang kuat pada foto.',
        order: 2,
      ),
      ModuleModel(
        id: 'M03',
        title: 'Framing within a Frame (Bingkai dalam Bingkai)',
        description: 'Gunakan elemen alami sebagai bingkai subjek',
        materialContent: 'Mencari "bingkai" alami di dalam lokasi pemotretan, seperti jendela, pintu, dedaunan, atau lubang bangunan untuk mengelilingi subjek. Teknik ini membantu mengisolasi subjek dan menciptakan dimensi.',
        order: 3,
      ),
      ModuleModel(
        id: 'M04',
        title: 'Symmetry and Patterns (Simetri dan Pola)',
        description: 'Temukan simetri atau pola berulang',
        materialContent: 'Simetri menciptakan rasa harmoni dan keseimbangan yang sempurna. Anda bisa mencari refleksi air atau arsitektur yang identik di kedua sisi. Sementara itu, pola yang berulang memberikan ritme visual yang menarik.',
        order: 4,
      ),
      ModuleModel(
        id: 'M05',
        title: 'Golden Triangle (Segitiga Emas)',
        description: 'Bagi frame diagonal menjadi segitiga',
        materialContent: 'Mirip dengan Rule of Thirds, namun menggunakan garis diagonal. Bagilah frame menjadi beberapa segitiga. Teknik ini sangat efektif untuk subjek yang memiliki garis miring atau dinamis agar foto tidak terasa kaku.',
        order: 5,
      ),
      ModuleModel(
        id: 'M06',
        title: 'Negative Space (Ruang Kosong)',
        description: 'Ruang kosong di sekitar subjek',
        materialContent: 'Memberikan banyak ruang kosong (seperti langit atau dinding polos) di sekitar subjek. Ini akan memberikan kesan minimalis, dramatis, dan memastikan perhatian penonton tertuju sepenuhnya pada subjek kecil di tengah ruang tersebut.',
        order: 6,
      ),
      ModuleModel(
        id: 'M07',
        title: 'Rule of Odds (Aturan Ganjil)',
        description: 'Foto dengan subjek berjumlah ganjil (3 atau 5)',
        materialContent: 'Mata manusia cenderung lebih nyaman melihat jumlah subjek yang ganjil (seperti 3 atau 5) dibandingkan genap. Jumlah ganjil terasa lebih alami dan tidak terlihat seperti "dipaksakan" atau terlalu simetris.',
        order: 7,
      ),
      ModuleModel(
        id: 'M08',
        title: 'Depth of Field (Kedalaman Bidang)',
        description: 'Pemisahan foreground-subjek-background (bokeh)',
        materialContent: 'Menciptakan pemisahan antara latar depan (foreground), subjek, dan latar belakang (background). Menggunakan bokeh (latar belakang kabur) adalah cara paling umum untuk membuat subjek tampak menonjol dari sekitarnya.',
        order: 8,
      ),
      ModuleModel(
        id: 'M09',
        title: 'Point of View (Sudut Pandang)',
        description: 'Sudut tidak biasa: bird\'s eye atau frog\'s eye',
        materialContent: 'Jangan hanya memotret dari ketinggian mata (eye-level). Cobalah memotret dari sudut yang tidak biasa, seperti:\n\nBird’s Eye View: Dari ketinggian menghadap ke bawah.\n\nFrog’s Eye View: Dari posisi sangat rendah menghadap ke atas.',
        order: 9,
      ),
      ModuleModel(
        id: 'M10',
        title: 'Center Dominance (Simetri Tengah)',
        description: 'Subjek tepat di tengah',
        materialContent: 'Meskipun Rule of Thirds menyarankan subjek di pinggir, menempatkan subjek tepat di tengah frame sangat efektif untuk potret wajah (portrait) atau subjek tunggal yang sangat kuat untuk memberikan kesan berwibawa dan fokus.',
        order: 10,
      ),
    ];
  }
}

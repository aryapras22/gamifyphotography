// lib/services/module_service.dart
// TASK-M04 — Migrasi dari hardcoded ke Firestore dengan fallback

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/module_model.dart';

class ModuleService {
  final _db = FirebaseFirestore.instance;

  /// Ambil semua modul dari Firestore, terurut by field 'order'.
  /// Fallback ke data hardcoded jika Firestore gagal atau kosong.
  Future<List<ModuleModel>> getModules() async {
    try {
      final snap = await _db.collection('modules').orderBy('order').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final raw = d.data();
          final data = <String, dynamic>{...raw, 'id': d.id};

          // Admin stores description inside page1.description (nested),
          // but ModuleModel.fromJson requires a top-level 'description'.
          // Extract it here so fromJson doesn't throw and fall back to hardcoded.
          if (!data.containsKey('description') || data['description'] == null) {
            final page1 = raw['page1'];
            data['description'] = (page1 is Map ? page1['description'] : null) ?? '';
          }

          // materialContent: use page1.description as a readable summary if absent
          if (!data.containsKey('materialContent') || data['materialContent'] == null || data['materialContent'] == '') {
            final page1 = raw['page1'];
            data['materialContent'] = (page1 is Map ? page1['description'] : null) ?? '';
          }

          // Extract howToUse and howToUseImageUrl from page2
          if (!data.containsKey('howToUse') || data['howToUse'] == null || data['howToUse'] == '') {
            final page2 = raw['page2'];
            data['howToUse'] = (page2 is Map ? page2['howToUse'] : null) ?? '';
          }

          if (!data.containsKey('howToUseImageUrl') || data['howToUseImageUrl'] == null) {
            final page2 = raw['page2'];
            data['howToUseImageUrl'] = (page2 is Map ? page2['howToUseImageUrl'] : null);
          }

          // Firestore tidak menyimpan isCompleted — default false
          data.putIfAbsent('isCompleted', () => false);
          data.putIfAbsent('levelCount', () => 0);
          data.putIfAbsent('type', () => 'materi');

          if (!data.containsKey('referenceImageUrls') || data['referenceImageUrls'] == null) {
            final page1 = raw['page1'];
            final urls = (page1 is Map ? page1['referenceImageUrls'] : null);
            data['referenceImageUrls'] = urls != null ? List<String>.from(urls) : <String>[];
          }

          return ModuleModel.fromJson(data);
        }).toList();
      }
    } catch (e) {
      debugPrint('[ModuleService] Firestore error, using fallback: $e');
    }
    // Fallback ke data hardcoded
    return _hardcodedModules();
  }

  List<ModuleModel> _hardcodedModules() => [
        ModuleModel(
          id: 'M01',
          title: 'Rule of Thirds (Aturan Sepertiga)',
          description: 'Letakkan subjek di titik potong garis sepertiga',
          howToUse: 'Letakkan subjek di titik potong garis sepertiga',
          materialContent:
              'Teknik yang paling dasar namun sangat ampuh. Bayangkan bidang foto dibagi menjadi 9 kotak dengan 2 garis horizontal dan 2 garis vertikal. Letakkan subjek utama di titik potong atau di sepanjang garis tersebut agar foto terlihat lebih seimbang dan natural.',
          order: 1,
        ),
        ModuleModel(
          id: 'M02',
          title: 'Leading Lines (Garis Penuntun)',
          description: 'Gunakan garis untuk mengarahkan mata ke subjek',
          howToUse: 'Gunakan garis untuk mengarahkan mata ke subjek',
          materialContent:
              'Gunakan garis-garis yang ada di sekitar (seperti jalan, pagar, jembatan, atau bayangan) untuk mengarahkan mata penonton menuju subjek utama.',
          order: 2,
        ),
        ModuleModel(
          id: 'M03',
          title: 'Framing within a Frame (Bingkai dalam Bingkai)',
          description: 'Gunakan elemen alami sebagai bingkai subjek',
          howToUse: 'Gunakan elemen alami sebagai bingkai subjek',
          materialContent:
              'Mencari "bingkai" alami di dalam lokasi pemotretan, seperti jendela, pintu, dedaunan, atau lubang bangunan untuk mengelilingi subjek.',
          order: 3,
        ),
        ModuleModel(
          id: 'M04',
          title: 'Symmetry and Patterns (Simetri dan Pola)',
          description: 'Temukan simetri atau pola berulang',
          howToUse: 'Temukan simetri atau pola berulang',
          materialContent:
              'Simetri menciptakan rasa harmoni dan keseimbangan yang sempurna.',
          order: 4,
        ),
        ModuleModel(
          id: 'M05',
          title: 'Golden Triangle (Segitiga Emas)',
          description: 'Bagi frame diagonal menjadi segitiga',
          howToUse: 'Bagi frame diagonal menjadi segitiga',
          materialContent:
              'Mirip dengan Rule of Thirds, namun menggunakan garis diagonal.',
          order: 5,
        ),
        ModuleModel(
          id: 'M06',
          title: 'Negative Space (Ruang Kosong)',
          description: 'Ruang kosong di sekitar subjek',
          howToUse: 'Ruang kosong di sekitar subjek',
          materialContent:
              'Memberikan banyak ruang kosong di sekitar subjek untuk kesan minimalis.',
          order: 6,
        ),
        ModuleModel(
          id: 'M07',
          title: 'Rule of Odds (Aturan Ganjil)',
          description: 'Foto dengan subjek berjumlah ganjil (3 atau 5)',
          howToUse: 'Foto dengan subjek berjumlah ganjil (3 atau 5)',
          materialContent:
              'Mata manusia cenderung lebih nyaman melihat jumlah subjek yang ganjil.',
          order: 7,
        ),
        ModuleModel(
          id: 'M08',
          title: 'Depth of Field (Kedalaman Bidang)',
          description: 'Pemisahan foreground-subjek-background (bokeh)',
          howToUse: 'Pemisahan foreground-subjek-background (bokeh)',
          materialContent:
              'Menciptakan pemisahan antara latar depan, subjek, dan latar belakang.',
          order: 8,
        ),
        ModuleModel(
          id: 'M09',
          title: 'Point of View (Sudut Pandang)',
          description: 'Sudut tidak biasa: bird\'s eye atau frog\'s eye',
          howToUse: 'Sudut tidak biasa: bird\'s eye atau frog\'s eye',
          materialContent:
              'Jangan hanya memotret dari ketinggian mata (eye-level).',
          order: 9,
        ),
        ModuleModel(
          id: 'M10',
          title: 'Center Dominance (Simetri Tengah)',
          description: 'Subjek tepat di tengah',
          howToUse: 'Subjek tepat di tengah',
          materialContent:
              'Menempatkan subjek tepat di tengah frame sangat efektif untuk potret wajah.',
          order: 10,
        ),
      ];
}

// lib/services/module_service.dart
// Firebase-only — no hardcoded fallback

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/module_model.dart';

class ModuleService {
  final _db = FirebaseFirestore.instance;

  /// Ambil semua modul dari Firestore, terurut by field 'order'.
  Future<List<ModuleModel>> getModules() async {
    final snap = await _db.collection('modules').orderBy('order').get();
    return snap.docs.map((d) {
      final raw = d.data();
      final data = <String, dynamic>{...raw, 'id': d.id};

      // Admin stores description inside page1.description (nested),
      // but ModuleModel.fromJson requires a top-level 'description'.
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
}

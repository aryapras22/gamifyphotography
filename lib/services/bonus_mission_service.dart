import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bonus_mission_model.dart';

class BonusMissionService {
  final FirebaseFirestore _db;

  BonusMissionService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Ambil semua bonus missions yang aktif, diurutkan by `order`
  Future<List<BonusMissionModel>> fetchAll() async {
    final snap = await _db
        .collection('bonus_missions')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return BonusMissionModel.fromJson(data);
    }).toList();
  }
}

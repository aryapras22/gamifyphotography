import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bonus_mission_service.dart';
import '../models/bonus_mission_model.dart';

final bonusMissionServiceProvider = Provider<BonusMissionService>(
  (_) => BonusMissionService(),
);

final bonusMissionsProvider = FutureProvider<List<BonusMissionModel>>((ref) {
  return ref.read(bonusMissionServiceProvider).fetchAll();
});

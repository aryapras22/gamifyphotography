import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crafting_item_model.dart';

final craftingItemsProvider = StreamProvider<List<CraftingItemModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('crafting_items')
      .where('isActive', isEqualTo: true)
      .orderBy('order')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => CraftingItemModel.fromJson({...d.data(), 'id': d.id}))
          .toList());
});

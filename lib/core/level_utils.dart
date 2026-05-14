// lib/core/level_utils.dart
// Single source of truth untuk kalkulasi level dari total XP.
// Gunakan fungsi ini di semua tempat yang menghitung atau menampilkan level.

/// Menghitung level berdasarkan total XP.
/// Level naik setiap 100 XP: 0–99 XP = Lv.1, 100–199 XP = Lv.2, dst.
int calculateLevel(int totalPoints) => (totalPoints ~/ 100) + 1;

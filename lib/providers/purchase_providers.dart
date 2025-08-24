import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PurchaseService {
  final Box prefs;
  PurchaseService(this.prefs);

  String _key(String levelId) => 'entitled_level_$levelId';

  bool isLevelUnlocked(String levelId) {
    // Default: beginner is free
    if (levelId == 'beginner') return true;
    return prefs.get(_key(levelId)) == true;
  }

  Future<void> unlockLevel(String levelId) async {
    await prefs.put(_key(levelId), true);
  }
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final prefs = Hive.box('prefs');
  return PurchaseService(prefs);
});

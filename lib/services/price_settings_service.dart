import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_settings_model.dart';

class PriceSettingsService {
  static final _doc =
      FirebaseFirestore.instance.collection('settings').doc('prices');

  static Future<PriceSettings> load() async {
    final snap = await _doc.get();
    if (!snap.exists || snap.data() == null) return PriceSettings.defaults;
    return PriceSettings.fromMap(snap.data()!);
  }

  static Future<void> save(PriceSettings settings) =>
      _doc.set(settings.toMap());
}

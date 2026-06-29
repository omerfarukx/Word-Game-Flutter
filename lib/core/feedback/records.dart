import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-game personal bests, persisted. Loaded into memory once so reads and
/// "is this a record?" checks are synchronous; writes go through to prefs.
class Records {
  Records._();
  static final Records instance = Records._();

  final Map<String, int> _values = {};
  SharedPreferences? _prefs;

  static const _prefix = 'record_';

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith(_prefix)) {
          final v = _prefs!.getInt(key);
          if (v != null) _values[key.substring(_prefix.length)] = v;
        }
      }
    } catch (e) {
      debugPrint('Records init error: $e');
    }
  }

  int best(String id) => _values[id] ?? 0;
  bool has(String id) => _values.containsKey(id);

  /// Records [value] for [id] and returns true if it's a new best.
  /// For time-style metrics pass [lowerIsBetter] so smaller wins.
  bool submit(String id, int value, {bool lowerIsBetter = false}) {
    final existing = _values[id];
    final isRecord = existing == null ||
        (lowerIsBetter ? value < existing : value > existing);
    if (isRecord) {
      _values[id] = value;
      _prefs?.setInt('$_prefix$id', value);
    }
    return isRecord;
  }
}

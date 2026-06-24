/// Tolerant JSON parsing helpers shared by model `fromJson` factories.
///
/// These NEVER throw on a bad stored value. Records load through the providers'
/// `_safeParseList`, which silently DROPS (debugPrint only) any entry whose
/// `fromJson` throws — so a single malformed field (a partial write, an
/// ISO-format drift, a hand-edited or cross-version backup) would permanently
/// delete a whole record (a future-self letter, an urge-ride win, a CBT thought
/// record). Parsing tolerantly keeps the record with a safe fallback instead.
///
/// Storage contract: these read the SAME keys and never change the write
/// format — they only make the read side resilient. See the 2026-06-23 audit.
library;

/// Parse a required date tolerantly. Returns [fallback] (epoch by default) for
/// a null / non-String / unparseable value instead of throwing.
DateTime safeParseDate(Object? v, {DateTime? fallback}) {
  if (v is String) {
    final parsed = DateTime.tryParse(v);
    if (parsed != null) return parsed;
  }
  return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
}

/// Parse an OPTIONAL date. Returns null for a null/unparseable value, preserving
/// the "not set" meaning (never fabricates a sentinel date).
DateTime? nullableParseDate(Object? v) =>
    v is String ? DateTime.tryParse(v) : null;

/// Read a required String, falling back to [fallback] for a null/non-String.
String safeString(Object? v, {String fallback = ''}) =>
    v is String ? v : fallback;

/// Read an int that a backup may have round-tripped as a double, or that may be
/// missing/wrong-typed on old/foreign data. Never throws (unlike `x as int`).
int safeInt(Object? v, {int fallback = 0}) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

/// Read a stable id, generating a unique fallback for a missing/blank/wrong
/// id rather than dropping the record. Mirrors VisionMilestone's existing
/// fallback behaviour.
String safeId(Object? v) => (v is String && v.isNotEmpty)
    ? v
    : 'gen_${DateTime.now().microsecondsSinceEpoch}';

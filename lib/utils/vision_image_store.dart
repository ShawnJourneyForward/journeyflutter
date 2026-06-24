import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persistent, update-safe storage for Vision Board photos.
///
/// ── The bug this fixes ──────────────────────────────────────────────────────
/// `image_picker` returns a path inside the app's *cache* directory. Android
/// treats cache as disposable: it is wiped under storage pressure, on a manual
/// "clear cache", and on some app updates. The board used to persist that
/// throwaway path verbatim, so the photo silently vanished while the vision
/// item kept a dead path string (`File(path).existsSync()` → false → no image).
///
/// ── The fix ─────────────────────────────────────────────────────────────────
/// Copy each picked photo into a permanent sub-directory of the app's documents
/// directory and persist only the **bare filename** — never an absolute path.
/// At render time we re-join the filename to the *current* documents directory.
///
/// Storing the bare filename (not the absolute path) is deliberate: it keeps the
/// photos resolving even if the documents base path ever changes across an OS /
/// path_provider upgrade — exactly the "don't lose my data on update" guarantee
/// we want. It also keeps the on-disk JSON contract intact: `imagePaths` stays a
/// `List<String>`, and legacy absolute entries still resolve through [resolve]
/// unchanged (they just won't exist on disk if the OS already cleared them).
class VisionImageStore {
  VisionImageStore._();

  static const _subDir = 'vision_images';

  /// Absolute path to the managed image directory, cached synchronously so the
  /// build()-time render code can resolve filenames without an `await`.
  static String? _baseDir;

  /// Monotonic suffix so two picks in the same microsecond can't collide.
  static int _seq = 0;

  /// Call once at startup (in `main`), before the first frame. Idempotent and
  /// never throws — on failure [_baseDir] stays null and photo features degrade
  /// gracefully (no crash, no user data touched).
  static Future<void> init() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}${Platform.pathSeparator}$_subDir');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      _baseDir = dir.path;
    } catch (e) {
      debugPrint('[VisionImageStore] init failed: $e');
    }
  }

  static bool get isReady => _baseDir != null;

  /// True when [stored] is a bare filename we manage (no path separators),
  /// rather than a legacy absolute path written by an older build.
  static bool _isBareFilename(String s) =>
      s.isNotEmpty && !s.contains('/') && !s.contains(r'\');

  /// Copy [sourcePath] (an image_picker temp file) into permanent storage and
  /// return the bare **filename** to persist. Returns null on failure so the
  /// caller can decide how to degrade rather than persisting a dead reference.
  static Future<String?> save(String sourcePath) async {
    // If startup init failed, try once more here rather than silently giving up
    // — a null return makes the caller fall back, and the caller must NOT then
    // persist the picker's cache path (that reproduces the original bug).
    if (_baseDir == null) await init();
    final base = _baseDir;
    if (base == null) return null;
    try {
      final src = File(sourcePath);
      if (!src.existsSync()) return null;
      final dot = sourcePath.lastIndexOf('.');
      // Keep a sane extension; default to .jpg (image_picker re-encodes to JPEG
      // when imageQuality is set, as it is at the call site).
      final ext = (dot >= 0 && sourcePath.length - dot <= 5)
          ? sourcePath.substring(dot)
          : '.jpg';
      final name = 'vb_${DateTime.now().microsecondsSinceEpoch}_${_seq++}$ext';
      await src.copy('$base${Platform.pathSeparator}$name');
      return name;
    } catch (e) {
      debugPrint('[VisionImageStore] save failed: $e');
      return null;
    }
  }

  /// Resolve a stored value to an absolute path. Accepts both new bare
  /// filenames (joined to the live base dir) and legacy absolute paths
  /// (returned as-is).
  static String resolve(String stored) {
    final base = _baseDir;
    if (base != null && _isBareFilename(stored)) {
      return '$base${Platform.pathSeparator}$stored';
    }
    return stored;
  }

  /// A [File] for a stored value, or null if it can't be resolved or the file
  /// no longer exists on disk. Lets render code show a graceful fallback.
  static File? fileFor(String stored) {
    final f = File(resolve(stored));
    return f.existsSync() ? f : null;
  }

  /// Base64 of a managed image's bytes, for bundling into a backup. Returns
  /// null for a legacy path, a missing file, or any read error.
  static Future<String?> readBytesB64(String stored) async {
    if (!_isBareFilename(stored)) return null;
    final f = fileFor(stored);
    if (f == null) return null;
    try {
      return base64Encode(await f.readAsBytes());
    } catch (e) {
      debugPrint('[VisionImageStore] readBytesB64 failed: $e');
      return null;
    }
  }

  /// Re-materialise a managed image file from a backup (decode [b64] into
  /// `<docs>/vision_images/<bareName>`). Best-effort; only ever writes a bare
  /// managed filename, never a legacy/absolute path.
  static Future<void> writeBytesB64(String bareName, String b64) async {
    if (!_isBareFilename(bareName)) return;
    if (_baseDir == null) await init();
    final base = _baseDir;
    if (base == null) return;
    try {
      final bytes = base64Decode(b64);
      await File('$base${Platform.pathSeparator}$bareName')
          .writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('[VisionImageStore] writeBytesB64 failed: $e');
    }
  }

  /// Delete the managed file for a stored value. No-op for legacy absolute
  /// paths (we never created those, so we must not touch them). Best-effort.
  static Future<void> delete(String stored) async {
    final base = _baseDir;
    if (base == null || !_isBareFilename(stored)) return;
    try {
      final f = File('$base${Platform.pathSeparator}$stored');
      if (f.existsSync()) await f.delete();
    } catch (e) {
      debugPrint('[VisionImageStore] delete failed: $e');
    }
  }
}

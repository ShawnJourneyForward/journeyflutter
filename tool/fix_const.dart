// One-shot migration helper for the dark-mode token refactor.
// AppColors/AppTextStyles members became getters, so every `const` expression
// that references them is now a compile error. This walks analyzer errors and
// removes the nearest enclosing `const` keyword (or rewrites `static const` /
// declaration `const` to `final`), iterating until fixed-point.
//
// Run from the project root:  dart run tool/fix_const.dart
import 'dart:convert';
import 'dart:io';

const targets = {
  'INVALID_CONSTANT',
  'CONST_WITH_NON_CONSTANT_ARGUMENT',
  'NON_CONSTANT_LIST_ELEMENT',
  'NON_CONSTANT_MAP_ELEMENT',
  'NON_CONSTANT_MAP_KEY',
  'NON_CONSTANT_MAP_VALUE',
  'NON_CONSTANT_SET_ELEMENT',
  'CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE',
};

void main() {
  for (var round = 1; round <= 25; round++) {
    final res = Process.runSync(
      r'C:\flutter\bin\dart.bat',
      ['analyze', '--format=machine', '.'],
      runInShell: true,
    );
    final lines = LineSplitter.split('${res.stdout}\n${res.stderr}');
    final perFile = <String, List<List<int>>>{};
    for (final l in lines) {
      final parts = l.split('|');
      if (parts.length < 8) continue;
      if (parts[0] != 'ERROR') continue;
      if (!targets.contains(parts[2])) continue;
      perFile
          .putIfAbsent(parts[3], () => [])
          .add([int.parse(parts[4]), int.parse(parts[5])]);
    }
    if (perFile.isEmpty) {
      stdout.writeln('round $round: clean — no target errors remain');
      return;
    }

    var fixes = 0;
    perFile.forEach((path, locs) {
      final original = File(path).readAsStringSync();
      final lineStarts = <int>[0];
      for (var i = 0; i < original.length; i++) {
        if (original.codeUnitAt(i) == 10) lineStarts.add(i + 1);
      }

      // Map every error to the nearest preceding `const` token in the
      // ORIGINAL text, dedupe, then apply deletions bottom-up so offsets
      // stay valid.
      final constRe = RegExp(r'\bconst\b');
      final constOffsets = <int>{};
      for (final lc in locs) {
        if (lc[0] - 1 >= lineStarts.length) continue;
        final off = lineStarts[lc[0] - 1] + (lc[1] - 1);
        Match? nearest;
        for (final m in constRe.allMatches(original)) {
          if (m.start >= off) break;
          nearest = m;
        }
        if (nearest != null) constOffsets.add(nearest.start);
      }

      var src = original;
      final sorted = constOffsets.toList()..sort((a, b) => b.compareTo(a));
      for (final start in sorted) {
        final before = src.substring(0, start);
        var after = src.substring(start + 'const'.length);
        final isStatic = RegExp(r'static\s+$').hasMatch(before);
        // Declaration form: `const name =` / `const Type name =`
        final isDecl =
            RegExp(r'^\s+[_A-Za-z][\w<>, ?]*(\s+[_A-Za-z]\w*)?\s*=').hasMatch(after);
        if (isStatic || isDecl) {
          src = '${before}final$after';
        } else {
          if (after.startsWith(' ')) after = after.substring(1);
          src = before + after;
        }
        fixes++;
      }
      File(path).writeAsStringSync(src);
    });
    stdout.writeln('round $round: ${perFile.length} files, $fixes const fixes');
  }
  stdout.writeln('hit round cap — remaining errors need manual fixes');
}

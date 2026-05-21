import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Thin wrapper around [SpeechToText] so the journal/affirmation screens don't
// each have to handle init/permission/error plumbing.
//
// Single global instance — speech_to_text under the hood is itself a singleton
// over the platform channel, but it stores listener state on the wrapper so
// re-instantiating mid-recognition drops callbacks.

class VoiceInput {
  VoiceInput._();
  static final VoiceInput instance = VoiceInput._();

  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  bool _available = false;

  bool get isListening => _stt.isListening;
  bool get isAvailable => _available;

  /// Returns true if the platform has speech recognition and the user has
  /// granted (or will be prompted for) microphone permission. Safe to call
  /// repeatedly; subsequent calls are cheap.
  Future<bool> init() async {
    if (_initialized) return _available;
    try {
      _available = await _stt.initialize(
        onError: (e) => debugPrint('[VoiceInput] error: ${e.errorMsg}'),
        onStatus: (s) => debugPrint('[VoiceInput] status: $s'),
      );
    } catch (e) {
      debugPrint('[VoiceInput] init threw: $e');
      _available = false;
    }
    _initialized = true;
    return _available;
  }

  /// Begin listening. [onResult] fires for partial AND final results — use
  /// [SpeechRecognitionResult.finalResult] to know when transcription is done.
  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
    String? localeId,
  }) async {
    if (!_available) {
      final ok = await init();
      if (!ok) return;
    }
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenFor: listenFor,
      pauseFor: pauseFor,
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stop() => _stt.stop();
  Future<void> cancel() => _stt.cancel();
}

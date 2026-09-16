import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService extends ChangeNotifier {
  VoiceService._();
  static final instance = VoiceService._();

  final _tts = FlutterTts();
  final _stt = SpeechToText();

  static const _kEnabled = 'voice_assistant_enabled';

  bool _enabled       = false;
  bool _sttReady      = false;
  bool _listening     = false;
  bool _speaking      = false;
  bool _userStopped   = true;
  bool _pendingRestart = false;

  // Words accumulated across restarted STT sessions
  String _accumulated = '';
  void Function(String)? _onPartialCallback;
  void Function(String)? _onFinalCallback;

  bool get isEnabled    => _enabled;
  bool get isListening  => _listening;
  bool get isSpeaking   => _speaking;
  bool get sttAvailable => _sttReady;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabled) ?? false;

    // TTS — French, comfortable reading speed
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() { _speaking = true; notifyListeners(); });
    _tts.setCompletionHandler(() { _speaking = false; notifyListeners(); });
    _tts.setCancelHandler(() { _speaking = false; notifyListeners(); });

    _sttReady = await _stt.initialize(
      onStatus: (String status) {
        if (status == 'listening') {
          _listening = true;
          notifyListeners();
        } else if (status == 'done' || status == 'notListening' || status == 'doneNoResult') {
          // Fallback restart for sessions that timed out without producing a finalResult
          // (e.g., silence timeout). finalResult-triggered restart is handled separately.
          if (!_userStopped && _listening) {
            _scheduleRestart();
          } else if (_userStopped) {
            _listening = false;
            notifyListeners();
          }
        }
      },
      onError: (SpeechRecognitionError error) {
        if (!_userStopped && !error.permanent) {
          _scheduleRestart();
        } else {
          _listening = false;
          notifyListeners();
        }
      },
    );
  }

  // ── Preference ─────────────────────────────────────────────────────────────

  Future<void> setEnabled(bool val) async {
    _enabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, val);
    if (!val) {
      await stopSpeaking();
      await stopListening();
    }
    notifyListeners();
  }

  // ── TTS ────────────────────────────────────────────────────────────────────

  Future<void> speak(String text) async {
    if (!_enabled) return;
    final clean = text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1')
        .replaceAll(RegExp(r'[*_`#>•]'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
    if (clean.isEmpty) return;
    await _tts.stop();
    await _tts.speak(clean);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _speaking = false;
    notifyListeners();
  }

  // ── STT ────────────────────────────────────────────────────────────────────

  Future<bool> startListening({
    required void Function(String text) onPartial,
    required void Function(String text) onFinal,
  }) async {
    if (!_sttReady || _listening) return false;
    _userStopped = false;
    _pendingRestart = false;
    _accumulated = '';
    _onPartialCallback = onPartial;
    _onFinalCallback = onFinal;
    _listening = true;
    notifyListeners();
    await _startSession();
    return true;
  }

  Future<void> _startSession() async {
    if (_userStopped || !_sttReady) return;
    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        final words = result.recognizedWords;
        if (result.finalResult) {
          // Append confirmed segment to the running buffer
          if (words.isNotEmpty) {
            _accumulated = _accumulated.isEmpty ? words : '$_accumulated $words';
          }
          // Show accumulated text while we wait for the restart
          if (!_userStopped) {
            _onPartialCallback?.call(_accumulated);
            // Trigger restart immediately from here — don't rely on onStatus alone
            _scheduleRestart();
          }
        } else {
          // In-progress: show buffer + current partial
          final display = _accumulated.isEmpty ? words : '$_accumulated $words';
          _onPartialCallback?.call(display);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'fr_FR',
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  // Schedules a restart with deduplication — won't fire twice if both
  // onResult.finalResult and onStatus trigger it in the same cycle.
  void _scheduleRestart() {
    if (_pendingRestart || _userStopped) return;
    _pendingRestart = true;
    Future.delayed(const Duration(milliseconds: 250), () async {
      _pendingRestart = false;
      if (_userStopped) return;
      // Explicitly stop the current session before starting a new one
      await _stt.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      if (_userStopped) return;
      await _startSession();
    });
  }

  Future<void> stopListening() async {
    _userStopped = true;
    _pendingRestart = false;
    if (_listening) {
      await _stt.stop();
      _listening = false;
      if (_accumulated.isNotEmpty) _onFinalCallback?.call(_accumulated);
      notifyListeners();
    }
  }
}

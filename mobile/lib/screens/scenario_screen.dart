// lib/screens/scenario_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../services/microphone_permission_service.dart';

import '../audio_helper.dart';
import '../data/exam_question_bank.dart';
import '../models/exam_attempt.dart';
import '../models/exam_question.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/practice_submission.dart';

class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final FlutterTts _tts = FlutterTts();
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isSending = false;
  bool _isTranslating = false;

  late final List<ExamQuestion> _scenarioQuestions;
  int _currentIndex = 0;

  String? _translatedQuestion;
  Map<String, dynamic>? _lastResult;
  DateTime? _webRecordingStart;

  ExamQuestion get _currentQuestion => _scenarioQuestions[_currentIndex];
  String get _questionText => _currentQuestion.text;

  int get _minValidRecordingBytes => kIsWeb ? 1200 : 3000;

  @override
  void initState() {
    super.initState();
    _scenarioQuestions =
        ExamQuestionBank.shuffledCopy(ExamQuestionBank.scenarioQuestions);
    _configureTts();
  }

  void _configureTts() {
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _tts.stop();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    await _tts.stop();
    await _tts.speak(_questionText);
  }

  Future<void> _translate() async {
    if (_isTranslating) return;
    setState(() => _isTranslating = true);
    try {
      final translated =
          await ApiService.translateQuestion(_questionText, targetLang: "tr");
      if (!mounted) return;
      setState(() {
        _translatedQuestion = translated;
        _isTranslating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTranslating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Çeviri alınırken hata: $e")),
      );
    }
  }

  void _newRandomScenario() {
    if (_isRecording || _isSending) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _scenarioQuestions.length;
      _translatedQuestion = null;
      _lastResult = null;
    });
  }

  void _goToNextScenario() {
    if (_isRecording || _isSending) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _scenarioQuestions.length;
      _translatedQuestion = null;
      _lastResult = null;
    });
  }

  Future<void> _toggleRecording() async {
    if (_isSending) return;
    if (_lastResult != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Önce "Sonraki senaryo" ile ilerle veya üstte yeni senaryo seç.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path == null || path.isEmpty) return;

      try {
        final recStart = _webRecordingStart;
        _webRecordingStart = null;
        if (kIsWeb &&
            recStart != null &&
            DateTime.now().difference(recStart) < const Duration(milliseconds: 450)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt çok kısa. 1 sn konuşup tekrar bırak.'),
              ),
            );
          }
          return;
        }
        final bytes = await getAudioBytesFromPath(path);
        if (bytes.length < _minValidRecordingBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  kIsWeb
                      ? 'Yeterli ses yok. Mikrofona basılı tutup tekrar dene.'
                      : 'Ses yeterli değil, tekrar dene.',
                ),
              ),
            );
          }
          return;
        }
        await _submitBytes(bytes);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayıt işlenemedi: $e')),
          );
        }
      }
      return;
    }

    if (kIsWeb) {
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mikrofon izni gerekli.')),
          );
        }
        return;
      }
    } else {
      if (!await MicrophonePermissionService.ensureGranted(context)) {
        return;
      }
    }

    String filePath;
    if (kIsWeb) {
      filePath = 'scenario_${_currentIndex}_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: filePath,
      );
      _webRecordingStart = DateTime.now();
    } else {
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      filePath = '${dir.path}/scenario_$ts.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: filePath,
      );
    }
    setState(() => _isRecording = true);
  }

  Future<void> _submitBytes(Uint8List bytes) async {
    if (!await canSubmitPractice(
      "scenario",
      featureLabel: "Senaryolar",
      context: context,
    )) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final result = await ApiService.sendScenarioAudio(
        bytes,
        scenarioText: _questionText,
        filename: kIsWeb ? 'answer.wav' : 'answer.m4a',
      );
      if (!mounted) return;

      final attempt = ExamAttempt.fromQuestionResult(
        question: _currentQuestion,
        type: 'scenario',
        result: result,
      );
      await HistoryService.addAttempt(attempt);
      await markFreePlanUsage("scenario");

      if (!mounted) return;
      setState(() {
        _lastResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Değerlendirme hatası: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String? _str(Map<String, dynamic>? m, String k) {
    if (m == null) return null;
    final v = m[k];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  int _roundScore(num? n) {
    if (n == null) return 0;
    return n.round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B1020);
    final hasEval = _lastResult != null;
    const accent = Colors.redAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Scenario"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _newRandomScenario,
            icon: const Icon(Icons.shuffle),
            tooltip: "Rastgele yeni senaryo",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Text(
                          "SCENARIO",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        color: Colors.white,
                        onPressed: _speak,
                        tooltip: "Senaryoyu sesli oku",
                      ),
                      _isTranslating
                          ? const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.translate),
                              color: accent,
                              onPressed: _translate,
                              tooltip: "Türkçe çeviri",
                            ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _questionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "İpucu: (1) Situation → (2) Action → (3) Result ile adım adım anlat.",
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
                  ),
                  if (_translatedQuestion != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        _translatedQuestion!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    _isRecording ? Icons.fiber_manual_record : Icons.info_outline,
                    color: _isRecording ? accent : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isSending
                          ? "Cevabın değerlendiriliyor..."
                          : hasEval
                              ? "Aşağıda değerlendirme var. Devam için “Sonraki senaryo”."
                              : _isRecording
                                  ? "Kayıt alınıyor; bitirmek için tekrar dokun."
                                  : "Mikrofona dokun ve cevabını kaydet.",
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: hasEval ? _buildEvalCard() : const SizedBox(height: 8),
              ),
            ),
            if (hasEval)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isRecording || _isSending ? null : _goToNextScenario,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.navigate_next),
                    label: const Text("Sonraki senaryo", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _isSending ? null : _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? accent : accent,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvalCard() {
    final r = _lastResult!;
    final sc = r['score'];
    final overall = _roundScore(sc is num ? sc : int.tryParse(sc.toString()) ?? 0);

    final fb = r['feedback'];
    Map<String, dynamic>? fbm;
    if (fb is Map) fbm = Map<String, dynamic>.from(fb);
    final comment = _str(fbm, 'overall_comment');
    final you = _str(fbm, 'verilen_yanit');
    final suggested = _str(fbm, 'corrected_answer');

    final ge = fbm?['grammar_errors'];
    final List<String> errLines = [];
    if (ge is List) {
      for (final e in ge) {
        final t = e?.toString().trim() ?? '';
        if (t.isNotEmpty) errLines.add(t);
      }
    }

    return Card(
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Değerlendirme",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "Senaryo puanı: $overall / 100",
                style: const TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (comment != null) ...[
              const SizedBox(height: 14),
              const Text(
                "Yorum",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
            if (you != null) ...[
              const SizedBox(height: 12),
              const Text(
                "Algılanan cevabın (özet)",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                you,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
            if (suggested != null && suggested.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Gelişmiş cevap önerisi (EN)",
                style: TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suggested,
                style: const TextStyle(
                  color: Color(0xFFFECACA),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
            if (errLines.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Dil notları",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...errLines.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "• $e",
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

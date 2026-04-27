// lib/screens/general_questions_screen.dart

import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../audio_helper.dart';
import '../data/exam_question_bank.dart';
import '../models/exam_attempt.dart';
import '../models/exam_question.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/practice_submission.dart';

class GeneralQuestionsScreen extends StatefulWidget {
  const GeneralQuestionsScreen({super.key});

  @override
  State<GeneralQuestionsScreen> createState() => _GeneralQuestionsScreenState();
}

class _GeneralQuestionsScreenState extends State<GeneralQuestionsScreen> {
  final FlutterTts _tts = FlutterTts();
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isSending = false;
  bool _isTranslating = false;

  late final List<ExamQuestion> _generalQuestions;
  int _currentIndex = 0;

  String? _translatedQuestion;
  /// Son değerlendirme (bu sayfada anlık gösterilir, sonra "Sonraki soru" ile temizlenir)
  Map<String, dynamic>? _lastResult;
  DateTime? _webRecordingStart;

  ExamQuestion get _currentQuestion => _generalQuestions[_currentIndex];
  String get _questionText => _currentQuestion.text;

  int get _minValidRecordingBytes => kIsWeb ? 1200 : 3000;

  @override
  void initState() {
    super.initState();
    _generalQuestions = ExamQuestionBank.generalQuestions;
    _configureTTS();
  }

  void _configureTTS() {
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

  void _newRandomQuestion() {
    if (_isRecording || _isSending) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _generalQuestions.length;
      _translatedQuestion = null;
      _lastResult = null;
    });
  }

  void _goToNextQuestion() {
    if (_isRecording || _isSending) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _generalQuestions.length;
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
            content: Text("Önce \"Sonraki soru\" ile ilerle veya üstteki yeni soru simgesine bas."),
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
      var st = await Permission.microphone.status;
      if (!st.isGranted) st = await Permission.microphone.request();
      if (!st.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mikrofon izni gerekli.')),
          );
        }
        return;
      }
    }

    String filePath;
    if (kIsWeb) {
      filePath = 'general_${_currentIndex}_${DateTime.now().millisecondsSinceEpoch}.wav';
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
      filePath = '${dir.path}/general_$ts.m4a';
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
      "general",
      featureLabel: "Genel sorular",
      context: context,
    )) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final result = await ApiService.sendGeneralAudio(
        bytes,
        filename: kIsWeb ? 'answer.wav' : 'answer.m4a',
      );
      if (!mounted) return;

      final attempt = ExamAttempt.fromQuestionResult(
        question: _currentQuestion,
        type: 'general',
        result: result,
      );
      await HistoryService.addAttempt(attempt);
      await markPracticeUseIfDemo("general");

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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("General"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _newRandomQuestion,
            icon: const Icon(Icons.shuffle),
            tooltip: "Rastgele yeni soru",
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
                          color: Colors.greenAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.greenAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Text(
                          "GENERAL",
                          style: TextStyle(
                            color: Colors.greenAccent,
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
                        tooltip: "Soruyu sesli oku",
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
                              color: Colors.greenAccent,
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
                  if (_translatedQuestion != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.25),
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
                    color: _isRecording ? Colors.redAccent : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isSending
                          ? "Cevabın değerlendiriliyor..."
                          : hasEval
                              ? "Aşağıda değerlendirme var. Sonraki soruya aşağıdaki butonla geç."
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
                    onPressed: _isRecording || _isSending ? null : _goToNextQuestion,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.navigate_next),
                    label: const Text("Sonraki soru", style: TextStyle(fontWeight: FontWeight.w700)),
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
                    color: _isRecording ? Colors.redAccent : Colors.greenAccent,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.redAccent : Colors.greenAccent)
                            .withValues(alpha: 0.35),
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
                child: CircularProgressIndicator(color: Colors.greenAccent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvalCard() {
    final r = _lastResult!;
    final sc = r['scores'];
    Map<String, dynamic>? sm;
    if (sc is Map) sm = Map<String, dynamic>.from(sc);
    int overall = _roundScore(sm?['overall'] as num?);
    int flu = _roundScore(sm?['fluency'] as num?);
    int gr = _roundScore(sm?['grammar'] as num?);
    int voc = _roundScore(sm?['vocabulary'] as num?);

    final fb = r['feedback'];
    Map<String, dynamic>? fbm;
    if (fb is Map) fbm = Map<String, dynamic>.from(fb);
    final comment = _str(fbm, 'overall_comment');
    final you = _str(fbm, 'verilen_yanit');
    final suggested = _str(fbm, 'corrected_answer');

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
                "Genel: $overall / 100",
                style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _chip("Akıcılık", flu),
                _chip("Gramer", gr),
                _chip("Kelime", voc),
              ],
            ),
            if (comment != null) ...[
              const SizedBox(height: 14),
              const Text("Yorum", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                comment,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
            ],
            if (you != null) ...[
              const SizedBox(height: 12),
              const Text("Algılanan cevabın (özet)", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                you,
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.35),
              ),
            ],
            if (suggested != null && suggested.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text("Gelişmiş cevap önerisi (EN)", style: TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                suggested,
                style: const TextStyle(color: Color(0xFF86EFAC), fontSize: 13, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.35)),
      ),
      child: Text(
        "$label: $v",
        style: const TextStyle(
          color: Color(0xFF22C55E),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

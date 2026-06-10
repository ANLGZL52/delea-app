// lib/screens/question_screen.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../services/microphone_permission_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../constants/exam_config.dart';
import '../constants/exam_question_labels.dart';
import '../models/exam_question.dart';
import '../data/exam_question_bank.dart';
import '../services/api_service.dart';
import '../audio_helper.dart';
import 'exam_result_screen.dart';

enum _QuestionPhase { thinking, recording, transitioning }

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final List<ExamQuestion> _questions;

  late final List<String?> _recordedPaths;
  late final List<Map<String, dynamic>?> _results;

  int _currentIndex = 0;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isEvaluating = false;

  int get _minValidRecordingBytes => kIsWeb ? 1200 : 3000;
  int _evaluatingIndex = 0;
  int _evaluatingTotal = 0;

  late final FlutterTts _tts;

  String? _currentTranslation;
  bool _isTranslating = false;

  _QuestionPhase _phase = _QuestionPhase.thinking;
  int _thinkingSecondsLeft = ExamConfig.thinkingSeconds;
  int _recordingSecondsElapsed = 0;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();

    _tts = FlutterTts();
    _configureTts();

    _questions = ExamQuestionBank.generateExam(
      introCount: ExamConfig.introCount,
      personalCount: ExamConfig.personalCount,
      generalCount: ExamConfig.generalCount,
      imageCount: ExamConfig.imageCount,
      scenarioCount: ExamConfig.scenarioCount,
    );

    _recordedPaths = List<String?>.filled(_questions.length, null);
    _results = List<Map<String, dynamic>?>.filled(_questions.length, null);

    _beginQuestionPhase();
  }

  void _configureTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
    _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _cancelPhaseTimer();
    _tts.stop();
    _recorder.dispose();
    super.dispose();
  }

  void _cancelPhaseTimer() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
  }

  ExamQuestion get _currentQuestion => _questions[_currentIndex];

  Future<void> _beginQuestionPhase() async {
    if (!mounted) return;
    setState(() {
      _phase = _QuestionPhase.thinking;
      _thinkingSecondsLeft = ExamConfig.thinkingSeconds;
      _recordingSecondsElapsed = 0;
    });
    await _speakCurrentQuestion();
    if (!mounted) return;
    _startThinkingTimer();
  }

  void _startThinkingTimer() {
    _cancelPhaseTimer();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_thinkingSecondsLeft <= 1) {
        timer.cancel();
        _startRecordingPhase();
      } else {
        setState(() => _thinkingSecondsLeft--);
      }
    });
  }

  void _skipThinking() {
    if (_phase != _QuestionPhase.thinking || _isEvaluating) return;
    _cancelPhaseTimer();
    _startRecordingPhase();
  }

  Future<void> _startRecordingPhase() async {
    if (!mounted || _isEvaluating) return;

    _cancelPhaseTimer();

    if (kIsWeb) {
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mikrofon izni gerekli. Adres çubuğundaki kilit veya izin simgesinden mikrofona izin verin.',
              ),
              duration: Duration(seconds: 5),
            ),
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
    RecordConfig config;
    if (kIsWeb) {
      filePath = 'recording_${_currentIndex + 1}.wav';
      config = const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
      );
    } else {
      final dir = await getTemporaryDirectory();
      filePath = '${dir.path}/answer_${_currentIndex + 1}.m4a';
      config = const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      );
    }

    await _recorder.start(config, path: filePath);

    if (!mounted) return;
    setState(() {
      _phase = _QuestionPhase.recording;
      _isRecording = true;
      _recordingSecondsElapsed = 0;
    });

    _startRecordingTimer();
  }

  void _startRecordingTimer() {
    _cancelPhaseTimer();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_recordingSecondsElapsed >= ExamConfig.recordingSeconds - 1) {
        timer.cancel();
        _finishRecordingAndAdvance();
      } else {
        setState(() => _recordingSecondsElapsed++);
      }
    });
  }

  Future<String?> _stopRecording() async {
    if (!_isRecording) return _recordedPaths[_currentIndex];
    final path = await _recorder.stop();
    if (mounted) {
      setState(() => _isRecording = false);
    }
    return path;
  }

  Future<bool> _saveRecording(String? path) async {
    if (path == null || path.isEmpty) return false;
    try {
      final bytes = await getAudioBytesFromPath(path);
      if (bytes.length < _minValidRecordingBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kIsWeb
                    ? 'Ses yeterince kaydedilmedi. Mikrofon iznini kontrol edip tekrar deneyin.'
                    : 'Ses kaydı algılanamadı. Gerçek cihazda tekrar deneyin.',
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return false;
      }
      _recordedPaths[_currentIndex] = path;
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt işlenemedi: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _finishRecordingAndAdvance() async {
    if (_phase == _QuestionPhase.transitioning || _isEvaluating) return;

    _cancelPhaseTimer();
    setState(() => _phase = _QuestionPhase.transitioning);

    final path = await _stopRecording();
    final saved = await _saveRecording(path);
    if (!saved && _recordedPaths[_currentIndex] == null) {
      if (mounted) {
        setState(() => _phase = _QuestionPhase.recording);
        await _startRecordingPhase();
      }
      return;
    }

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _currentTranslation = null;
      });
      await _beginQuestionPhase();
    } else {
      await _evaluateAllAtEnd();
    }
  }

  Future<void> _speakCurrentQuestion() async {
    final q = _currentQuestion;
    await _tts.stop();

    String textToRead = q.text;
    if (q.type == 'image') {
      textToRead =
          'Image based question. Please describe the picture in detail. ${q.text}';
    }

    await _tts.speak(textToRead);
  }

  Future<void> _translateCurrentQuestion() async {
    if (_phase == _QuestionPhase.recording) return;

    final q = _currentQuestion;

    if (_currentTranslation != null) {
      _showTranslationDialog(_currentTranslation!);
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final translated = await ApiService.translateQuestion(q.text);
      if (!mounted) return;

      setState(() {
        _currentTranslation = translated;
        _isTranslating = false;
      });

      _showTranslationDialog(translated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTranslating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çeviri alınırken hata oluştu: $e')),
      );
    }
  }

  void _showTranslationDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Türkçe Çeviri'),
        content: SingleChildScrollView(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _evaluateAllAtEnd() async {
    final toEvaluate = <int>[];
    for (int i = 0; i < _questions.length; i++) {
      if (!ExamConfig.shouldEvaluate(i)) continue;
      final path = _recordedPaths[i];
      if (path != null && path.isNotEmpty) toEvaluate.add(i);
    }
    if (toEvaluate.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Değerlendirilecek geçerli ses kaydı yok.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isEvaluating = true;
      _evaluatingTotal = toEvaluate.length;
      _evaluatingIndex = 0;
    });

    try {
      final batchItems = <Map<String, dynamic>>[];
      final batchIndices = <int>[];
      for (final i in toEvaluate) {
        final path = _recordedPaths[i]!;
        final bytes = await getAudioBytesFromPath(path);
        if (bytes.length < _minValidRecordingBytes) continue;
        final q = _questions[i];
        final ext = kIsWeb ? 'wav' : 'm4a';
        batchItems.add({
          'bytes': bytes,
          'filename': 'answer_${i + 1}.$ext',
          'questionId': q.id,
          'questionType': q.type,
          'questionText': q.text,
        });
        batchIndices.add(i);
      }

      if (batchItems.isEmpty) {
        if (mounted) {
          setState(() => _isEvaluating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gönderilecek geçerli ses kaydı yok.')),
          );
        }
        return;
      }

      setState(() => _evaluatingIndex = batchItems.length);
      final resultsList = await ApiService.sendAudioBatch(batchItems);

      if (!mounted) return;
      for (var k = 0; k < resultsList.length && k < batchIndices.length; k++) {
        _results[batchIndices[k]] = resultsList[k];
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isEvaluating = false);
      final msg = e.toString().split('\n').first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Değerlendirme yapılamadı: $msg. Backend çalışıyor ve OPENAI_API_KEY ayarlı mı?',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isEvaluating = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          questions: _questions,
          results: _results,
        ),
      ),
    );
  }

  Color get _micColor {
    if (_phase == _QuestionPhase.recording) {
      return const Color(0xFF22C55E);
    }
    return const Color(0xFF64748B);
  }

  String get _phaseHint {
    switch (_phase) {
      case _QuestionPhase.thinking:
        return 'Düşünme süresi. Hazır olduğunda "Cevap Ver"e basabilirsin.';
      case _QuestionPhase.recording:
        return 'Kayıt alınıyor. İstediğin zaman "Sıradaki soru"ya geçebilirsin.';
      case _QuestionPhase.transitioning:
        return 'Sonraki soruya geçiliyor…';
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    final total = _questions.length;
    final current = _currentIndex + 1;

    final isImageQuestion = q.type == 'image';
    final hasImage =
        isImageQuestion && q.imageUrl != null && q.imageUrl!.isNotEmpty;

    final isThinking = _phase == _QuestionPhase.thinking;
    final isRecording = _phase == _QuestionPhase.recording;

    if (_isEvaluating) {
      return Scaffold(
        backgroundColor: const Color(0xFF050509),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '$_evaluatingIndex / $_evaluatingTotal cevap değerlendirildi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cevaplarınız detaylı şekilde analiz ediliyor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Simulation'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Soru $current / $total',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ExamQuestionLabels.typeLabel(q.type),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isRecording
                            ? const Color(0xFF22C55E).withOpacity(0.12)
                            : const Color(0xFF3B82F6).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRecording
                              ? const Color(0xFF22C55E).withOpacity(0.4)
                              : const Color(0xFF3B82F6).withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isThinking ? 'Düşünme süresi' : 'Cevap verme süresi',
                            style: TextStyle(
                              fontSize: 13,
                              color: isRecording
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isThinking
                                ? '$_thinkingSecondsLeft sn'
                                : '$_recordingSecondsElapsed / ${ExamConfig.recordingSeconds} sn',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (hasImage) ...[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: (MediaQuery.of(context).size.height * 0.32)
                              .clamp(160.0, 280.0),
                        ),
                        child: ClipRrectImage(url: q.imageUrl!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      q.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    if (isThinking)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 30),
                            onPressed: _speakCurrentQuestion,
                            tooltip: 'Soruyu sesli dinle',
                          ),
                          const SizedBox(width: 16),
                          _isTranslating
                              ? const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.translate, size: 26),
                                  onPressed: _translateCurrentQuestion,
                                  tooltip: 'Türkçe çeviri',
                                ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _micColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _phaseHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  if (isThinking)
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _skipThinking,
                        child: const Text('Cevap Ver'),
                      ),
                    ),
                  if (isRecording) ...[
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _finishRecordingAndAdvance,
                        child: Text(
                          current < total ? 'Sıradaki soru' : 'Sınavı bitir',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Küçük helper widget: asset/network image + border radius + graceful fallback
class ClipRrectImage extends StatelessWidget {
  final String url;
  const ClipRrectImage({super.key, required this.url});

  bool get _isAsset => !url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isAsset) {
      child = Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const _ImageErrorFallback();
        },
      );
    } else {
      child = Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const _ImageErrorFallback();
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black12,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: child,
        ),
      ),
    );
  }
}

class _ImageErrorFallback extends StatelessWidget {
  const _ImageErrorFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          'Image could not be loaded.\n'
          'You can still answer by describing a typical scene related to the question.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

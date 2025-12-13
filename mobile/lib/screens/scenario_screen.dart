// lib/screens/scenario_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/exam_question.dart';
import '../data/exam_question_bank.dart';
import '../services/api_service.dart';
import '../models/exam_attempt.dart';
import '../services/history_service.dart';
import 'exam_result_screen.dart';

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

  ExamQuestion get _currentQuestion => _scenarioQuestions[_currentIndex];
  String get _questionText => _currentQuestion.text;

  @override
  void initState() {
    super.initState();
    _scenarioQuestions = ExamQuestionBank.scenarioQuestions;
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

  void _newScenario() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _scenarioQuestions.length;
      _translatedQuestion = null;
    });
  }

  Future<void> _toggleRecording() async {
    if (_isSending) return;

    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        await _sendAudio(File(path));
      }
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mikrofon izni gerekli.")),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${dir.path}/scenario_$ts.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: filePath,
    );

    setState(() => _isRecording = true);
  }

  Future<void> _sendAudio(File file) async {
    setState(() => _isSending = true);

    try {
      final result = await ApiService.sendScenarioAudio(
        file,
        scenarioText: _questionText,
      );

      final examQuestion = _currentQuestion;

      // Geçmişe kaydet
      final attempt = ExamAttempt.fromQuestionResult(
        question: examQuestion,
        type: 'scenario',
        result: result,
      );
      await HistoryService.addAttempt(attempt);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExamResultScreen(
            questions: [examQuestion],
            results: [result],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Değerlendirme hatası: $e")),
        );
      }
    }

    if (!mounted) return;
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B1020);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Scenario"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _newScenario,
            icon: const Icon(Icons.shuffle),
            tooltip: "Yeni Senaryo",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scenario Card
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.35),
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
                              color: Colors.redAccent,
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
                    "İpucu: (1) Situation → (2) Action → (3) Result formatıyla adım adım anlat.",
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
                  ),

                  if (_translatedQuestion != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.25),
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

            // status
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
                          : _isRecording
                              ? "Kayıt alınıyor, bitirmek için tekrar dokun."
                              : "Mikrofona dokun ve cevabını kaydet.",
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // mic
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 26),
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.redAccent : Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.35),
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
                padding: EdgeInsets.only(bottom: 18),
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}

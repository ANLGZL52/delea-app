// lib/screens/scenario_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/exam_question.dart';
import '../data/exam_question_bank.dart';
import '../services/api_service.dart';
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

  /// 🔹 Tüm senaryo soruları havuzu
  late final List<ExamQuestion> _scenarioQuestions;
  int _currentIndex = 0;

  /// Çevrilmiş hali
  String? _translatedQuestion;

  ExamQuestion get _currentQuestion => _scenarioQuestions[_currentIndex];
  String get _questionText => _currentQuestion.text;

  @override
  void initState() {
    super.initState();
    _scenarioQuestions = ExamQuestionBank.scenarioQuestions;
    _configureTTS();
  }

  void _configureTTS() {
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  void _speak() {
    _tts.speak(_questionText);
  }

  Future<void> _translate() async {
    try {
      final translated =
          await ApiService.translateQuestion(_questionText, targetLang: "tr");

      setState(() {
        _translatedQuestion = translated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Çeviri alınırken hata: $e")),
      );
    }
  }

  /// 🔄 Yeni senaryo: havuzdaki bir SONRAKİ senaryoya geç
  Future<void> _newScenario() async {
    setState(() {
      _currentIndex =
          (_currentIndex + 1) % _scenarioQuestions.length; // sona gelince başa dön
      _translatedQuestion = null; // her yeni senaryoda çeviriyi sıfırla
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        await _sendAudio(File(path));
      }
      return;
    }

    if (!await _recorder.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mikrofon izni gerekli.")),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/scenario_answer.m4a';

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
      // 🔴 Burada backend'e senaryonun metnini de gönderiyoruz
      final result = await ApiService.sendScenarioAudio(
        file,
        scenarioText: _questionText,
      );

      final examQuestion = _currentQuestion;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Değerlendirme hatası: $e")),
      );
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Senaryolar"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🟥 Senaryo kartı
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_alt,
                          color: Colors.redAccent),
                      const SizedBox(width: 6),
                      const Text(
                        "Senaryo",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Sesli okutma
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.white),
                        onPressed: _speak,
                      ),
                      // Çeviri
                      IconButton(
                        icon: const Icon(Icons.translate,
                            color: Colors.redAccent),
                        onPressed: _translate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _questionText,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  if (_translatedQuestion != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _translatedQuestion!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 👇 Senin açıklama cümlen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                "Bu senaryoda kabin memuru olarak ne yapmanız gerektiğini adım adım, detaylı bir şekilde anlatın.",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 16),

            // 🔁 Yeni senaryo düğmesi (tam genişlik)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _newScenario,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    "Yeni Senaryo",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // 🎙 Mikrofon butonu
            GestureDetector(
              onTap: _isSending ? null : _toggleRecording,
              child: Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, size: 40, color: Colors.black),
              ),
            ),

            if (_isSending)
              const Padding(
                padding: EdgeInsets.only(bottom: 25),
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}

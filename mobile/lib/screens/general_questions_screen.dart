// lib/screens/general_questions_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../services/api_service.dart';
import '../models/exam_question.dart';
import '../data/exam_question_bank.dart';
import 'exam_result_screen.dart';

// 🔐 DEMO / PREMIUM kontrolü için eklenen importlar
import '../services/plan_service.dart';
import '../widgets/demo_limit_dialog.dart';

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

  // 🔹 Tüm genel sorular havuzu
  late final List<ExamQuestion> _generalQuestions;
  int _currentIndex = 0;

  // Çevrilmiş hali
  String? _translatedQuestion;

  ExamQuestion get _currentQuestion => _generalQuestions[_currentIndex];
  String get _questionText => _currentQuestion.text;

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Çeviri alınırken hata: $e")),
      );
    }
  }

  /// 🔄 Yeni soru: havuzdaki bir SONRAKİ soruya geç
  Future<void> _newQuestion() async {
    setState(() {
      _currentIndex =
          (_currentIndex + 1) % _generalQuestions.length; // sona gelince başa dön
      _translatedQuestion = null; // her yeni soruda çeviriyi sıfırla
    });
  }

  Future<void> _toggleRecording() async {
    // Eğer şu anda kayıttaysak → kaydı durdur
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        await _sendAudio(File(path));
      }
      return;
    }

    // Gönderim sırasında yeniden başlatma izni verme
    if (_isSending) return;

    // 🎯 DEMO / PREMIUM KONTROLÜ
    final canUse = await PlanService.canUseFeature("general");
    if (!canUse) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const DemoLimitDialog(
          featureName: "General Questions",
        ),
      );
      return;
    }

    // Mikrofon izni
    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mikrofon izni gerekli.")),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/general_question.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: filePath,
    );

    // ✔ Kullanım hakkını kaydet → bugün için bu sekmeden sadece 1 kayıt
    await PlanService.registerUsage("general");

    setState(() => _isRecording = true);
  }

  Future<void> _sendAudio(File file) async {
    setState(() => _isSending = true);

    try {
      final result = await ApiService.sendGeneralAudio(file);

      // 🔹 Sorunun kendisini, soru ID/type ile birlikte gönderiyoruz
      final examQuestion = _currentQuestion;

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
      if (!mounted) return;
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
        title: const Text("Genel Sorular"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🟩 Soru kartı
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat, color: Colors.greenAccent),
                      const SizedBox(width: 6),
                      const Text(
                        "Soru",
                        style: TextStyle(
                          color: Colors.greenAccent,
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
                            color: Colors.greenAccent),
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
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _translatedQuestion!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 🔁 Yeni soru düğmesi
            TextButton.icon(
              onPressed: _newQuestion,
              icon: const Icon(Icons.refresh, color: Colors.greenAccent),
              label: const Text(
                "Yeni Soru",
                style: TextStyle(color: Colors.greenAccent, fontSize: 16),
              ),
            ),

            const Spacer(),

            // 🎙 Mikrofon
            GestureDetector(
              onTap: _isSending ? null : _toggleRecording,
              child: Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.greenAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.4),
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
                child: CircularProgressIndicator(color: Colors.greenAccent),
              ),
          ],
        ),
      ),
    );
  }
}

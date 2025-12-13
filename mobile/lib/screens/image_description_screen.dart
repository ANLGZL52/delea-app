// lib/screens/image_description_screen.dart

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/exam_question.dart';
import '../services/api_service.dart';
import '../models/exam_attempt.dart';
import '../services/history_service.dart';
import 'exam_result_screen.dart';

class ImageDescriptionScreen extends StatefulWidget {
  const ImageDescriptionScreen({super.key});

  @override
  State<ImageDescriptionScreen> createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen> {
  final FlutterTts _tts = FlutterTts();
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isSending = false;

  late final List<String> _imagePaths;
  int _currentIndex = 0;

  static const String _imagePromptEn = "Describe this picture in detail.";
  static const String _imagePromptTr = "Bu resmi ayrıntılı bir şekilde açıklayın.";

  String get _currentImagePath => _imagePaths[_currentIndex];

  @override
  void initState() {
    super.initState();

    _imagePaths = List.generate(
      14,
      (i) => 'assets/pexels_images/img_${i + 1}.jpg',
    );

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

  Future<void> _speakPrompt() async {
    await _tts.stop();
    await _tts.speak(_imagePromptEn);
  }

  void _newImage() {
    if (_imagePaths.length <= 1) return;

    final rand = Random();
    int newIndex = _currentIndex;
    while (newIndex == _currentIndex) {
      newIndex = rand.nextInt(_imagePaths.length);
    }

    setState(() => _currentIndex = newIndex);
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
    final filePath = '${dir.path}/image_desc_$ts.m4a';

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
      final result = await ApiService.sendImageAudio(
        file,
        _imagePromptEn,
      );

      final examQuestion = ExamQuestion(
        id: 'img_${_currentIndex + 1}',
        type: 'image',
        text: _imagePromptEn,
        imageUrl: _currentImagePath,
      );

      // Geçmişe kaydet
      final attempt = ExamAttempt.fromQuestionResult(
        question: examQuestion,
        type: 'image',
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
        title: const Text("Image"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSending ? null : _newImage,
            icon: const Icon(Icons.shuffle),
            tooltip: "Yeni Resim",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ÜST KART
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                          color: Colors.tealAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.tealAccent.withOpacity(0.35)),
                        ),
                        child: const Text(
                          "IMAGE",
                          style: TextStyle(
                            color: Colors.tealAccent,
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
                        onPressed: _speakPrompt,
                        tooltip: "Prompt'u sesli oku",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    _imagePromptTr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "İpucu: Overview (1) → Details (3) → Inference (1).",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            // RESİM
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1E293B)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      _currentImagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          "Görsel yüklenemedi.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // STATUS
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

            const SizedBox(height: 10),

            // MIC
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 20),
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.redAccent : Colors.tealAccent,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.redAccent : Colors.tealAccent)
                          .withOpacity(0.35),
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
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),
          ],
        ),
      ),
    );
  }
}

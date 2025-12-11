// lib/screens/image_description_screen.dart

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/exam_question.dart';
import '../services/api_service.dart';
import 'exam_result_screen.dart';

// 🔐 DEMO / PREMIUM kontrolü için eklenen importlar
import '../services/plan_service.dart';
import '../widgets/demo_limit_dialog.dart';

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

  // 🔹 Kullanılacak resimlerin asset path listesi
  late final List<String> _imagePaths;
  int _currentIndex = 0;

  // Ekranda kullanılacak İngilizce/Türkçe prompt
  static const String _imagePromptEn = "Describe this picture in detail.";
  static const String _imagePromptTr =
      "Bu resmi ayrıntılı bir şekilde açıklayın:";

  String get _currentImagePath => _imagePaths[_currentIndex];

  @override
  void initState() {
    super.initState();

    // img_1.jpg ... img_14.jpg
    _imagePaths = List.generate(
      14,
      (i) => 'assets/pexels_images/img_${i + 1}.jpg',
    );

    _currentIndex = 0;
    _configureTTS();
  }

  void _configureTTS() {
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  // 🗣 Promptu sesli okut
  void _speakPrompt() {
    _tts.speak(_imagePromptEn);
  }

  // 🔁 Yeni resim seç
  void _newImage() {
    if (_imagePaths.length <= 1) return;

    final rand = Random();
    int newIndex = _currentIndex;

    // Aynı resme denk gelmemek için tekrar çek
    while (newIndex == _currentIndex) {
      newIndex = rand.nextInt(_imagePaths.length);
    }

    setState(() {
      _currentIndex = newIndex;
    });
  }

  Future<void> _toggleRecording() async {
    // Halihazırda kayıt varsa → durdur & gönder
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        await _sendAudio(File(path));
      }
      return;
    }

    // Gönderim sırasında yeniden başlatma yok
    if (_isSending) return;

    // 🎯 DEMO / PREMIUM KONTROLÜ
    final canUse = await PlanService.canUseFeature("image");
    if (!canUse) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const DemoLimitDialog(
          featureName: "Image Description",
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
    final filePath = '${dir.path}/image_description.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: filePath,
    );

    // ✔ Kullanım hakkını kaydet → bugün için bu sekmeden sadece 1 kayıt
    await PlanService.registerUsage("image");

    setState(() => _isRecording = true);
  }

  Future<void> _sendAudio(File file) async {
    setState(() => _isSending = true);

    try {
      // Backend'e ses + prompt gönder
      final result = await ApiService.sendImageAudio(
        file,
        _imagePromptEn,
      );

      // Sonuç ekranı için soru objesi
      final examQuestion = ExamQuestion(
        id: 'img_${_currentIndex + 1}',
        type: 'image',
        text: _imagePromptEn,
        imageUrl: _currentImagePath,
      );

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
        title: const Text("Resim Açıklama"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Başlık + prompt + SESLİ OKUMA BUTONU
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image_outlined,
                          color: Colors.tealAccent),
                      const SizedBox(width: 6),
                      const Text(
                        "Resim Açıklama",
                        style: TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon:
                            const Icon(Icons.volume_up, color: Colors.white),
                        onPressed: _speakPrompt,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    _imagePromptTr,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            // 🖼 Resim: ekranın kalan dikey alanını doldurur, taşmaz
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox.expand(
                    child: Image.asset(
                      _currentImagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔁 Yeni Resim butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _newImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    "Yeni Resim",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🎙 Mikrofon
            GestureDetector(
              onTap: _isSending ? null : _toggleRecording,
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.tealAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, size: 40, color: Colors.black),
              ),
            ),

            if (_isSending)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),
          ],
        ),
      ),
    );
  }
}

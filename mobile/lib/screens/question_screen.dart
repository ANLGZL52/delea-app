// lib/screens/question_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 🔊 TTS

import '../models/exam_question.dart';
import '../data/exam_question_bank.dart';
import '../services/api_service.dart';
import 'exam_result_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final List<ExamQuestion> _questions;
  late final List<Map<String, dynamic>?> _results; // her soru için sonuç

  int _currentIndex = 0;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isSending = false;

  // 🔊 Text-to-Speech
  late final FlutterTts _tts;

  // 🌐 Çeviri state
  String? _currentTranslation;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();

    // TTS init
    _tts = FlutterTts();
    _configureTts();

    // 13 soruluk set
    _questions = ExamQuestionBank.generateExam(
      introCount: 2,
      generalCount: 6,
      imageCount: 3,
      scenarioCount: 2,
    );

    // Başta tüm sonuçlar null
    _results = List<Map<String, dynamic>?>.filled(_questions.length, null);

    // İlk soruyu otomatik sesli oku
    _speakCurrentQuestion();
  }

  void _configureTts() {
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45); // biraz yavaş, anlaşılır tempo
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _tts.stop(); // TTS'i durdur
    _recorder.dispose();
    super.dispose();
  }

  ExamQuestion get _currentQuestion => _questions[_currentIndex];

  // 🔊 Mevcut soruyu sesli okuyan fonksiyon
  Future<void> _speakCurrentQuestion() async {
    final q = _currentQuestion;

    await _tts.stop();

    String textToRead = q.text;

    if (q.type == 'image') {
      textToRead =
          "Image based question. Please describe the picture in detail. ${q.text}";
    }

    await _tts.speak(textToRead);
  }

  // 🌐 Mevcut soruyu Türkçeye çevir
  Future<void> _translateCurrentQuestion() async {
    final q = _currentQuestion;

    // Aynı soruda çeviri varsa direkt göster
    if (_currentTranslation != null) {
      _showTranslationDialog(_currentTranslation!);
      return;
    }

    setState(() {
      _isTranslating = true;
    });

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
      setState(() {
        _isTranslating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çeviri alınırken hata oluştu: $e')),
      );
    }
  }

  void _showTranslationDialog(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // ✅ Kaydı durdur
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        await _sendAudioToBackend(File(path));
      }
    } else {
      // ✅ Kayda başla
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mikrofon izni gerekli.')),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/answer_${_currentIndex + 1}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _sendAudioToBackend(File file) async {
    setState(() => _isSending = true);

    try {
      final q = _currentQuestion;

      // Tek endpoint: /evaluate
      final result = await ApiService.sendAudio(
        file,
        questionId: q.id,
        questionType: q.type,
        questionText: q.text,
      );

      // Bu sorunun sonucunu sakla (ekranda hemen göstermiyoruz)
      _results[_currentIndex] = result;

      setState(() {
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Değerlendirme hatası: $e')),
      );
    }
  }

  void _goNext() async {
    // Eğer hâlâ kayıt devam ediyorsa durdurup son cevabı gönder
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        await _sendAudioToBackend(File(path));
      }
    }

    // Hâlâ değerlendiriliyorsa beklet
    if (_isSending) return;

    // Son soruda mıyız?
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _currentTranslation = null; // yeni soruda çeviri sıfırlansın
      });

      // 🔊 Yeni soruya geçince otomatik sesli oku
      await _speakCurrentQuestion();
    } else {
      // Sınav bitti → sonuç ekranına git
      if (!mounted) return;
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
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    final total = _questions.length;
    final current = _currentIndex + 1;

    final isImageQuestion = q.type == 'image';
    final hasImage = isImageQuestion && q.imageUrl != null && q.imageUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Simulation'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ÜST KISIM: soru sayacı + soru tipi + görsel + metin
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question $current / $total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.type.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    if (hasImage) ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 260,
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

                    // 🔊 Sesli okuma + 🌐 Çeviri butonları
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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

            // 🔹 ALT KISIM: mic + açıklama + next butonu
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _isSending ? null : _toggleRecording,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? Colors.redAccent
                              : Colors.blueAccent,
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSending
                        ? 'Cevabın değerlendiriliyor...'
                        : _isRecording
                            ? 'Kayıt alınıyor, bitirmek için tekrar dokun.'
                            : 'Mikrofona dokunarak cevabını kaydet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isRecording || _isSending) ? null : _goNext,
                      child: Text(
                        current < total ? 'Next Question' : 'Finish Exam',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Küçük helper widget: network / asset image + border radius + graceful fallback
class ClipRrectImage extends StatelessWidget {
  final String url;
  const ClipRrectImage({super.key, required this.url});

  bool get _isAsset => !url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isAsset) {
      // assets/ içinden resim
      child = Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const _ImageErrorFallback();
        },
      );
    } else {
      // İleride network görsel kullanmak istersen hâlâ destekli
      child = Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return const Center(
            child: CircularProgressIndicator(),
          );
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

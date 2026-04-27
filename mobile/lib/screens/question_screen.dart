// lib/screens/question_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../constants/exam_config.dart';
import '../models/exam_question.dart';
import '../data/exam_question_bank.dart';
import '../services/api_service.dart';
import '../audio_helper.dart';
import 'exam_result_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final List<ExamQuestion> _questions;

  /// Her soru için kaydedilen ses dosyası yolu (sınav sonunda değerlendirilecek)
  late final List<String?> _recordedPaths;

  /// Sınav sonunda OpenAI ile değerlendirme sonuçları
  late final List<Map<String, dynamic>?> _results;

  int _currentIndex = 0;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  /// Web: kayıt başlama (çok kısa dokunuşlarda anlamsız / boş webm hatası önlenir)
  DateTime? _webRecordingStart;
  bool _isEvaluating = false;

  /// Aynı eşik: mikr. durdur, Sonraki ve toplu API; sessiz/çok kısa dosya giderilmesin
  int get _minValidRecordingBytes => kIsWeb ? 1200 : 3000;
  int _evaluatingIndex = 0;
  int _evaluatingTotal = 0;

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

    _questions = ExamQuestionBank.generateExam(
      introCount: ExamConfig.introCount,
      generalCount: ExamConfig.generalCount,
      imageCount: ExamConfig.imageCount,
      scenarioCount: ExamConfig.scenarioCount,
    );

    _recordedPaths = List<String?>.filled(_questions.length, null);
    _results = List<Map<String, dynamic>?>.filled(_questions.length, null);

    // İlk soruyu otomatik sesli oku
    _speakCurrentQuestion();
  }

  void _configureTts() {
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
    _tts.setVolume(1.0);
    // Tarayıcı ile emülatör/cihaz farklı TTS motoru kullandığı için ses farklı olabilir
  }

  @override
  void dispose() {
    _tts.stop();
    _recorder.dispose();
    super.dispose();
  }

  ExamQuestion get _currentQuestion => _questions[_currentIndex];

  // 🔊 Mevcut soruyu sesli okur
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

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null && path.isNotEmpty) {
        try {
          final recStart = _webRecordingStart;
          _webRecordingStart = null;
          final bytes = await getAudioBytesFromPath(path);
          final minDuration = recStart == null
              ? Duration.zero
              : DateTime.now().difference(recStart);
          // Web: önce opus+MediaRecorder (çok kısa/boş webm) sorunluydu; artık WAV. Yine de kısa tık engeli.
          final tooShort = kIsWeb && minDuration < const Duration(milliseconds: 450);
          if (tooShort) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Kayıt çok kısa. Mikrofona basılı tutun, 1 sn konuşup bırakın.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            }
            return;
          }
          if (bytes.length < _minValidRecordingBytes) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    kIsWeb
                        ? 'Ses yeterince kaydedilmedi. Mikrofon iznini, Chrome’da şifresiz (localhost) veya HTTPS sayfa olduğunuzu ve doğru girdi (mik) seçimini kontrol edin; bir kez daha deneyin.'
                        : 'Ses kaydı algılanamadı. Emülatörde mikrofon sorunlu olabilir. '
                            'Sesli cevap için gerçek cihazda deneyin.',
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } else {
            _recordedPaths[_currentIndex] = path;
            setState(() {});
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cevap kaydedildi. Sonraki soruya geçebilirsin.')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kayıt işlenemedi: $e')),
            );
          }
        }
      }
      return;
    }

    if (kIsWeb) {
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mikrofon izni gerekli. Adres çubuğundaki kilit veya izin simgesinden mikrofona izin verin; sayfa http ise yalnızca localhost güvenlidir (HTTPS tercih edin).',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    } else {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mikrofon izni gerekli. Ayarlardan izin verin.'),
            ),
          );
        }
        return;
      }
    }

    String filePath;
    RecordConfig config;
    if (kIsWeb) {
      // WebM+Opus (MediaRecorder) kısa/kırılgan; WAV AudioWorklet ile stabil (OpenAI tüm türü kabul eder).
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

    if (kIsWeb) {
      _webRecordingStart = DateTime.now();
    }
    setState(() => _isRecording = true);
  }

  /// Sınav sonunda tüm kayıtları tek istekte backend'e gönderir (batch); backend OpenAI ile paralel değerlendirir.
  Future<void> _evaluateAllAtEnd() async {
    final toEvaluate = <int>[];
    for (int i = 0; i < _questions.length; i++) {
      final path = _recordedPaths[i];
      if (path != null && path.isNotEmpty) toEvaluate.add(i);
    }
    if (toEvaluate.isEmpty) return;

    setState(() {
      _isEvaluating = true;
      _evaluatingTotal = toEvaluate.length;
      _evaluatingIndex = 0;
    });

    try {
      // Batch: tek istekte gönder – backend OpenAI ile paralel değerlendirir
      final batchItems = <Map<String, dynamic>>[];
      final batchIndices = <int>[]; // batchItems[k] hangi soru indeksi
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

  Future<void> _goNext() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      _webRecordingStart = null;
      if (path != null) {
        try {
          final bytes = await getAudioBytesFromPath(path);
          if (bytes.length < _minValidRecordingBytes) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bu soru için yeterli ses yok. Mikrofona basılı tutup 1 sn konuşup, '
                    "önce mavi düğmeye tekrar deyip 'Cevap kaydedildi' mesajını bekle, sonra ileri.",
                  ),
                  duration: Duration(seconds: 5),
                ),
              );
            }
            return;
          }
          _recordedPaths[_currentIndex] = path;
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kayıt okunamadı: $e')),
            );
          }
          return;
        }
      }
    }

    if (_isEvaluating) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _currentTranslation = null;
      });
      await _speakCurrentQuestion();
      return;
    }

    // Son soru – değerlendirme aşamasına geç
    final recordedCount = _recordedPaths.where((p) => p != null).length;
    if (recordedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir soruya cevap kaydetmelisin.'),
        ),
      );
      return;
    }

    await _evaluateAllAtEnd();
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    final total = _questions.length;
    final current = _currentIndex + 1;

    final isImageQuestion = q.type == 'image';
    final hasImage =
        isImageQuestion && q.imageUrl != null && q.imageUrl!.isNotEmpty;

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
                  const SizedBox(height: 8),
                  Text(
                    'Cevaplar paralel analiz ediliyor.\n'
                    'Her soru için konuşma, gramer ve kelime inceleniyor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
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
            // 🔹 Üst kısım
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question $current / $total',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.type.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
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

                    // 🔊 Sesli okuma + 🌐 çeviri butonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 30),
                          onPressed: _speakCurrentQuestion,
                          tooltip: kIsWeb
                              ? 'Soruyu sesli dinle (tarayıcı sesi)'
                              : 'Soruyu sesli dinle',
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

            // 🔹 Alt kısım: mic + açıklama + next
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: (_isEvaluating ? null : _toggleRecording),
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
                    _isRecording
                        ? 'Kayıt alınıyor, bitirmek için tekrar dokun.'
                        : _recordedPaths[_currentIndex] != null
                            ? 'Cevap kaydedildi. Sonraki soruya geçebilirsin.'
                            : 'Mikrofona dokunarak cevabını kaydet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isRecording || _isEvaluating) ? null : _goNext,
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

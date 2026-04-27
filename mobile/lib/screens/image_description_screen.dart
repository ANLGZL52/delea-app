// lib/screens/image_description_screen.dart

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../audio_helper.dart';
import '../data/exam_image_assets.dart';
import '../models/exam_attempt.dart';
import '../models/exam_question.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/practice_submission.dart';

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

  /// Kuyruk: tüm görseller bir kez bitene kadar tekrar yok; bitince (mevcut hariç) yeniden karılır.
  final List<String> _queue = [];
  late String _currentPath;

  static const String _imagePromptEn = "Describe this picture in detail.";
  static const String _imagePromptTr = "Bu resmi ayrıntılı bir şekilde açıklayın.";

  Map<String, dynamic>? _lastResult;
  DateTime? _webRecordingStart;

  int get _minValidRecordingBytes => kIsWeb ? 1200 : 3000;

  String get _currentImagePath => _currentPath;

  @override
  void initState() {
    super.initState();

    final all = List<String>.from(ExamImageAssets.allPaths());
    all.shuffle(Random());
    _currentPath = all.removeAt(0);
    _queue.addAll(all);

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
    if (_queue.isEmpty) {
      final rest = List<String>.from(ExamImageAssets.allPaths())
        ..remove(_currentPath);
      if (rest.isEmpty) return;
      rest.shuffle(Random());
      _queue.addAll(rest);
    }
    setState(() {
      _lastResult = null;
      _currentPath = _queue.removeAt(0);
    });
  }

  void _shuffleNewImage() {
    if (_isRecording || _isSending) return;
    _newImage();
  }

  void _goToNextImage() {
    if (_isRecording || _isSending) return;
    _newImage();
  }

  Future<void> _toggleRecording() async {
    if (_isSending) return;

    if (_lastResult != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Önce "Sonraki resim" ile ilerle veya üstte yeni resim seç.'),
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
      filePath = 'image_${DateTime.now().millisecondsSinceEpoch}.wav';
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
      filePath = '${dir.path}/image_desc_$ts.m4a';
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
      "image",
      featureLabel: "Resim açıklama",
      context: context,
    )) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final result = await ApiService.sendImageAudio(
        bytes,
        _imagePromptEn,
        filename: kIsWeb ? 'answer.wav' : 'answer.m4a',
      );
      if (!mounted) return;

      final n = ExamImageAssets.allPaths().indexOf(_currentPath) + 1;
      final examQuestion = ExamQuestion(
        id: 'img_$n',
        type: 'image',
        text: _imagePromptEn,
        imageUrl: _currentImagePath,
      );

      final attempt = ExamAttempt.fromQuestionResult(
        question: examQuestion,
        type: 'image',
        result: result,
      );
      await HistoryService.addAttempt(attempt);
      await markPracticeUseIfDemo("image");

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
    const accent = Colors.tealAccent;
    final hasEval = _lastResult != null;

    Widget imageBlock = Padding(
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
            width: double.infinity,
            errorBuilder: (_, __, ___) => const Center(
              child: Text(
                "Görsel yüklenemedi.",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Image"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSending ? null : _shuffleNewImage,
            icon: const Icon(Icons.shuffle),
            tooltip: "Yeni resim",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                          color: Colors.tealAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.tealAccent.withValues(alpha: 0.35),
                          ),
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
                              ? "Aşağıda değerlendirme var. Devam için “Sonraki resim”."
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
              child: hasEval
                  ? Column(
                      children: [
                        Expanded(flex: 2, child: imageBlock),
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: _buildEvalCard(accent),
                          ),
                        ),
                      ],
                    )
                  : imageBlock,
            ),

            if (hasEval)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isRecording || _isSending ? null : _goToNextImage,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.navigate_next),
                    label: const Text(
                      "Sonraki resim",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
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
                    color: _isRecording ? Colors.redAccent : accent,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.redAccent : accent)
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
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvalCard(Color accent) {
    final r = _lastResult!;
    final sc = r['score'];
    final overall = _roundScore(
      sc is num ? sc : int.tryParse(sc.toString()) ?? 0,
    );

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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                "Resim açıklama puanı: $overall / 100",
                style: TextStyle(
                  color: accent,
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
              Text(
                "Gelişmiş cevap önerisi (EN)",
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suggested,
                style: TextStyle(
                  color: accent.withValues(alpha: 0.85),
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

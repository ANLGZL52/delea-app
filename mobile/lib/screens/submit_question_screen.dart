// lib/screens/submit_question_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubmitQuestionScreen extends StatefulWidget {
  const SubmitQuestionScreen({super.key});

  @override
  State<SubmitQuestionScreen> createState() => _SubmitQuestionScreenState();
}

class _SubmitQuestionScreenState extends State<SubmitQuestionScreen> {
  final _questionController = TextEditingController();
  final _emailController = TextEditingController();

  final List<String> _categories = [
    'Genel İngilizce sorusu',
    'Senaryo önerisi',
    'Resim açıklama önerisi',
    'Sözlük / kelime talebi',
    'Diğer',
  ];

  String _selectedCategory = 'Genel İngilizce sorusu';
  bool _isSending = false;

  @override
  void dispose() {
    _questionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final question = _questionController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? null
        : _emailController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir soru veya öneri yaz.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final ok = await ApiService.submitUserQuestion(
        category: _selectedCategory,
        question: question,
        email: email,
      );

      setState(() => _isSending = false);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sorun başarıyla gönderildi, teşekkürler!')),
        );
        _questionController.clear();
        _emailController.clear();
        setState(() {
          _selectedCategory = _categories[0];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bir hata oluştu, lütfen tekrar dene.')),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sunucu hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      appBar: AppBar(
        title: const Text('Soru Gönder'),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uygulama için yeni soru, senaryo veya geliştirme önerilerini buradan iletebilirsin.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),

            // Kategori
            const Text(
              'Kategori',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF111827),
                  iconEnabledColor: Colors.white70,
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Soru / öneri metni
            const Text(
              'Soru / Öneri',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _questionController,
                maxLines: 6,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      'Örn: Senaryolarda x konusunu da görmek istiyorum...\n'
                      'Örn: DLA sınavında şu tarz bir soru da gelebilir...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Opsiyonel e-posta
            const Text(
              'E-posta (isteğe bağlı)',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'İstersen iletişim için e-posta bırakabilirsin.',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _submit,
                icon: _isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSending ? 'Gönderiliyor...' : 'Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

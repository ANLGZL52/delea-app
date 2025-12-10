import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum DictionaryDirection {
  enToTr,
  trToEn,
}

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  DictionaryDirection _direction = DictionaryDirection.enToTr;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final word = _controller.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kelime yaz.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final data = await ApiService.lookupWord(word);
      setState(() {
        _isLoading = false;
        _result = data;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sunucu hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Backend’ten gelen gerçek alanlar
    final word = _result?['word']?.toString() ?? '';
    final definitionEn = _result?['definition_en']?.toString() ?? '';
    final definitionTr = _result?['definition_tr']?.toString() ?? '';
    final exampleSentence = _result?['example_sentence']?.toString() ?? '';
    final dlaTip = _result?['dla_tip']?.toString() ?? '';
    final synonyms = (_result?['synonyms'] as List?)?.cast<String>() ?? [];

    final isEnToTr = _direction == DictionaryDirection.enToTr;

    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Akıllı Sözlük',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // 🔄 Dil yönü seçimi (EN -> TR / TR -> EN)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _direction = DictionaryDirection.enToTr;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isEnToTr
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🇺🇸  ➜  🇹🇷',
                          style: TextStyle(
                            color: isEnToTr ? Colors.white : Colors.white70,
                            fontWeight:
                                isEnToTr ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _direction = DictionaryDirection.trToEn;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: !isEnToTr
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🇹🇷  ➜  🇺🇸',
                          style: TextStyle(
                            color: !isEnToTr ? Colors.white : Colors.white70,
                            fontWeight:
                                !isEnToTr ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔍 Arama barı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      hintText: isEnToTr
                          ? 'Örn: turbulence, aisle, cabin crew...'
                          : 'Örn: türbülans, koridor, kabin memuru...',
                      hintStyle:
                          const TextStyle(color: Colors.white38, fontSize: 13),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                        borderSide:
                            BorderSide(color: Colors.lightBlueAccent, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🔻 Alt kısım: sonuç ya da boş mesaj
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBody(
                hasResult: _result != null,
                word: word,
                definitionEn: definitionEn,
                definitionTr: definitionTr,
                exampleSentence: exampleSentence,
                dlaTip: dlaTip,
                synonyms: synonyms,
                isEnToTr: isEnToTr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required bool hasResult,
    required String word,
    required String definitionEn,
    required String definitionTr,
    required String exampleSentence,
    required String dlaTip,
    required List<String> synonyms,
    required bool isEnToTr,
  }) {
    if (!hasResult && !_isLoading) {
      return const Center(
        child: Text(
          'DLA sınavında sık kullanabileceğin kelimeleri arayabilirsin.',
          style: TextStyle(color: Colors.white60),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!hasResult) {
      // loading durumunda ya da henüz veri yokken boş alan
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kelime
            Text(
              word.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Ana anlam (yön seçimine göre)
            Text(
              isEnToTr ? 'Türkçe Anlamı' : 'English Meaning',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEnToTr ? definitionTr : definitionEn,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),

            // Diğer açıklama
            Text(
              isEnToTr ? 'English Explanation' : 'Türkçe Açıklama',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEnToTr ? definitionEn : definitionTr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),

            if (synonyms.isNotEmpty) ...[
              const Text(
                'Benzer Kelimeler',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: synonyms
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
            ],

            if (exampleSentence.isNotEmpty) ...[
              const Text(
                'Örnek Cümle',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exampleSentence,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
            ],

            if (dlaTip.isNotEmpty) ...[
              const Text(
                'DLA İpucu',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dlaTip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

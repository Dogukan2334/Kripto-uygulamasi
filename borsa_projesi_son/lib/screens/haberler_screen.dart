import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Linki açmak için gerekli paket
import '../models/news_model.dart';
import '../services/api_services.dart';

class HaberlerScreen extends StatefulWidget {
  const HaberlerScreen({super.key});

  @override
  State<HaberlerScreen> createState() => _HaberlerScreenState();
}

class _HaberlerScreenState extends State<HaberlerScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<NewsModel>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _apiService.fetchNews();
  }

  // YENİ: Linki tarayıcıda açan fonksiyon
  Future<void> _haberLinkiniAc(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Açılmazsa konsola hata yazdır (Kullanıcıya da uyarı verilebilir)
      debugPrint("Link açılamadı: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsModel>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00B050)));
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Haberler yüklenemedi.", style: TextStyle(color: Colors.grey)));
        }

        final newsList = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];

            // YENİ: Kartı InkWell ile sarmaladık
            return Card(
              color: const Color(0xFF2C2C2C),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12), // Tıklama efektinin köşeleri taşmasın
                onTap: () {
                  // Tıklanınca linki aç
                  _haberLinkiniAc(news.url);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resim
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        news.imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container(
                            height: 150,
                            color: Colors.grey[800],
                            child: const Icon(Icons.article, size: 50, color: Colors.grey)
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.title,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.source, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(news.source, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const Spacer(),
                              // Sağ alt köşeye küçük bir "Oku" ikonu ekledim
                              const Text("Habere Git >", style: TextStyle(color: Color(0xFF00B050), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
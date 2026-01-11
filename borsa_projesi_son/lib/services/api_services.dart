import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Hafıza için
import 'package:translator/translator.dart'; // Çeviri için
import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';
import '../models/news_model.dart';

class ApiService {
  final GoogleTranslator _translator = GoogleTranslator();

  // --- AYARLAR ---
  // Liste için bekleme süresi: 5 Dakika
  final int _listCacheTime = 5 * 60 * 1000;
  // Detay ve Grafik için bekleme süresi: 10 Dakika (Daha az değişirler)
  final int _detailCacheTime = 10 * 60 * 1000;

  // 1. PİYASA VERİLERİ (LİSTE) - ÖNBELLEKLİ
  final String _apiUrl =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=try&order=market_cap_desc&per_page=100&page=1&sparkline=false";

  Future<List<CoinModel>> fetchCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('coins_list_cache');
    final int? lastTime = prefs.getInt('coins_list_time');
    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    // Önbellek geçerli mi?
    if (cachedData != null && lastTime != null && (currentTime - lastTime) < _listCacheTime) {
      print("✅ LİSTE Hafızadan Geldi");
      List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList.map((jsonItem) => CoinModel.fromJson(jsonItem)).toList();
    }

    try {
      print("🌐 LİSTE API'den Çekiliyor...");
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        // Kaydet ve döndür
        await prefs.setString('coins_list_cache', response.body);
        await prefs.setInt('coins_list_time', currentTime);

        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((jsonItem) => CoinModel.fromJson(jsonItem)).toList();
      } else if (response.statusCode == 429 && cachedData != null) {
        // Hata varsa ama eski veri varsa onu kullan
        List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList.map((jsonItem) => CoinModel.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Veri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      if (cachedData != null) {
        List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList.map((jsonItem) => CoinModel.fromJson(jsonItem)).toList();
      }
      throw Exception('Hata: $e');
    }
  }

  // 2. DETAY VERİSİ - ÖNBELLEKLİ VE ÇEVİRİLİ
  Future<CoinDetailModel> fetchCoinDetails(String coinId) async {
    final prefs = await SharedPreferences.getInstance();
    // Her coin için ayrı anahtar: "detail_bitcoin", "detail_ethereum" vb.
    final String cacheKey = 'detail_$coinId';
    final String timeKey = 'detail_time_$coinId';

    final String? cachedData = prefs.getString(cacheKey);
    final int? lastTime = prefs.getInt(timeKey);
    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    // Önbellek kontrolü
    if (cachedData != null && lastTime != null && (currentTime - lastTime) < _detailCacheTime) {
      print("✅ DETAY Hafızadan Geldi ($coinId)");
      // Hafızadaki veri zaten işlenmiş ve çevrilmiş JSON olacak
      return CoinDetailModel.fromJson(jsonDecode(cachedData));
    }

    // API İsteği
    final String detailApiUrl =
        "https://api.coingecko.com/api/v3/coins/$coinId?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false";

    try {
      print("🌐 DETAY API'den Çekiliyor ($coinId)...");
      final response = await http.get(Uri.parse(detailApiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        // --- ÇEVİRİ İŞLEMİ BURADA YAPILIP KAYDEDİLECEK ---
        String originalDesc = json['description']['en'] ?? '';
        String cleanDesc = _stripHtml(originalDesc);
        String translatedDesc = "Açıklama bulunamadı.";

        if (cleanDesc.isNotEmpty) {
          try {
            var translation = await _translator.translate(cleanDesc, to: 'tr');
            translatedDesc = translation.text;
          } catch (e) {
            translatedDesc = cleanDesc;
          }
        }

        // JSON'ı güncelle (İngilizce yerine Türkçeyi koyuyoruz ki hafızaya öyle kaydolsun)
        json['description']['en'] = translatedDesc;

        // İşlenmiş veriyi kaydet
        await prefs.setString(cacheKey, jsonEncode(json));
        await prefs.setInt(timeKey, currentTime);

        return CoinDetailModel.fromJson(json);
      } else if (response.statusCode == 429 && cachedData != null) {
        return CoinDetailModel.fromJson(jsonDecode(cachedData));
      } else {
        throw Exception('Detay hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (cachedData != null) return CoinDetailModel.fromJson(jsonDecode(cachedData));
      throw Exception('Hata: $e');
    }
  }

  // 3. GRAFİK VERİSİ - ÖNBELLEKLİ
  Future<List<List<dynamic>>> fetchCoinChartData(String coinId) async {
    final prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'chart_$coinId';
    final String timeKey = 'chart_time_$coinId';

    final String? cachedData = prefs.getString(cacheKey);
    final int? lastTime = prefs.getInt(timeKey);
    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (cachedData != null && lastTime != null && (currentTime - lastTime) < _detailCacheTime) {
      print("✅ GRAFİK Hafızadan Geldi ($coinId)");
      List<dynamic> json = jsonDecode(cachedData);
      return List<List<dynamic>>.from(json);
    }

    final String chartApiUrl =
        "https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=try&days=7";

    try {
      print("🌐 GRAFİK API'den Çekiliyor ($coinId)...");
      final response = await http.get(Uri.parse(chartApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        List<dynamic> prices = json['prices'];

        // Kaydet
        await prefs.setString(cacheKey, jsonEncode(prices));
        await prefs.setInt(timeKey, currentTime);

        return List<List<dynamic>>.from(prices);
      } else if (response.statusCode == 429 && cachedData != null) {
        return List<List<dynamic>>.from(jsonDecode(cachedData));
      } else {
        throw Exception('Grafik hatası');
      }
    } catch (e) {
      if (cachedData != null) return List<List<dynamic>>.from(jsonDecode(cachedData));
      throw Exception('Hata: $e');
    }
  }

  String _stripHtml(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
  }

  // 4. HABERLER (Aynı Kalıyor)
  Future<List<NewsModel>> fetchNews() async {
    const String newsUrl = "https://min-api.cryptocompare.com/data/v2/news/?lang=EN";
    try {
      final response = await http.get(Uri.parse(newsUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['Data'];
        return data.map((item) => NewsModel.fromJson(item)).toList();
      } else {
        throw Exception('Haberler alınamadı');
      }
    } catch (e) {
      throw Exception('Haber Hatası: $e');
    }
  }

  // 5. RADAR (Aynı Kalıyor)
  Future<List<CoinModel>> fetchTrending() async {
    const String trendUrl = "https://api.coingecko.com/api/v3/search/trending";
    try {
      final response = await http.get(Uri.parse(trendUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> coins = json['coins'];
        return coins.map((item) {
          final itemCoin = item['item'];
          return CoinModel(
            id: itemCoin['id'],
            symbol: itemCoin['symbol'],
            name: itemCoin['name'],
            image: itemCoin['large'],
            currentPrice: 0.0,
            priceChangePercentage24h: 0.0,
          );
        }).toList();
      } else {
        throw Exception('Trend verisi alınamadı');
      }
    } catch (e) {
      throw Exception('Trend Hatası: $e');
    }
  }
}
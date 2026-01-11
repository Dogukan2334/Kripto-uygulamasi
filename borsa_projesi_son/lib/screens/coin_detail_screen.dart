import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/coin_detail_model.dart';
import '../services/api_services.dart';

// Verileri bir arada tutan paket
class CoinDetailPageData {
  final CoinDetailModel details;
  final List<List<dynamic>> chartData;
  final bool hasError; // Hata var mı kontrolü

  CoinDetailPageData({
    required this.details,
    required this.chartData,
    this.hasError = false
  });
}

class CoinDetailScreen extends StatefulWidget {
  final String coinId;

  const CoinDetailScreen({
    super.key,
    required this.coinId,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<CoinDetailPageData> _pageDataFuture;

  @override
  void initState() {
    super.initState();
    _pageDataFuture = _loadPageData();
  }

  // Verileri yükleyen fonksiyon
  Future<CoinDetailPageData> _loadPageData() async {
    CoinDetailModel? details;
    List<List<dynamic>>? chartData;
    bool errorOccured = false;

    // 1. ADIM: Detayları Çek
    try {
      details = await _apiService.fetchCoinDetails(widget.coinId);
    } catch (e) {
      debugPrint("Detay hatası: $e");
      errorOccured = true;
      // Hata durumunda geçici veri
      details = CoinDetailModel(
          id: widget.coinId,
          name: widget.coinId.toUpperCase(),
          largeImage: '',
          description: '' // Boş bıraktık, aşağıda kontrol edeceğiz
      );
    }

    // 2. ADIM: API'yi Rahatlatmak İçin Bekle (Süreyi 1 saniyeye çıkardık)
    await Future.delayed(const Duration(seconds: 1));

    // 3. ADIM: Grafiği Çek
    try {
      chartData = await _apiService.fetchCoinChartData(widget.coinId);
    } catch (e) {
      debugPrint("Grafik hatası: $e");
      chartData = [];
    }

    return CoinDetailPageData(
        details: details!,
        chartData: chartData!,
        hasError: errorOccured
    );
  }

  // Yenileme Fonksiyonu
  void _retryLoading() {
    setState(() {
      _pageDataFuture = _loadPageData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(widget.coinId.toUpperCase()),
        actions: [
          // Sağ üst köşeye de yenileme butonu koyalım
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryLoading,
          )
        ],
      ),
      body: FutureBuilder<CoinDetailPageData>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          // YÜKLENİYOR...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00B050)),
                  SizedBox(height: 16),
                  Text("Veriler Analiz Ediliyor...", style: TextStyle(color: Colors.grey))
                ],
              ),
            );
          }

          final data = snapshot.data;

          // EĞER CİDDİ BİR HATA VARSA VE HİÇBİR ŞEY GELMEDİYSE
          if (data == null || (data.hasError && data.details.largeImage.isEmpty && data.chartData.isEmpty)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    "Sunucu çok yoğun (429 Hatası)",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Lütfen 5-10 saniye bekleyip tekrar deneyin.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _retryLoading,
                    icon: const Icon(Icons.refresh),
                    label: const Text("TEKRAR DENE"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B050),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                    ),
                  )
                ],
              ),
            );
          }

          // VERİ GELDİ (VEYA KISMEN GELDİ)
          final coinDetail = data.details;
          final chartData = data.chartData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo ve İsim
                Row(
                  children: [
                    if (coinDetail.largeImage.isNotEmpty)
                      Image.network(
                        coinDetail.largeImage,
                        height: 60,
                        width: 60,
                        errorBuilder: (_,__,___) => const Icon(Icons.currency_bitcoin, size: 60, color: Colors.grey),
                      )
                    else
                      const Icon(Icons.currency_bitcoin, size: 60, color: Colors.grey),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        coinDetail.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, color: Color(0xFF444444)),

                // GRAFİK ALANI
                const Text(
                  "7 Günlük Fiyat Grafiği (TRY)",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                chartData.isEmpty
                    ? Container(
                  height: 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.show_chart, color: Colors.grey, size: 40),
                      const SizedBox(height: 8),
                      const Text("Grafik yüklenemedi", style: TextStyle(color: Colors.grey)),
                      TextButton(
                          onPressed: _retryLoading,
                          child: const Text("Yenile", style: TextStyle(color: Color(0xFF00B050)))
                      )
                    ],
                  ),
                )
                    : SizedBox(
                  height: 200,
                  child: _buildChart(chartData),
                ),

                const Divider(height: 30, color: Color(0xFF444444)),

                // AÇIKLAMA ALANI
                const Text(
                  "Açıklama",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Açıklama kontrolü
                if (coinDetail.description.isEmpty || data.hasError)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3))
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Yoğunluk nedeniyle açıklama alınamadı.",
                            style: TextStyle(color: Colors.orangeAccent),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _retryLoading,
                        )
                      ],
                    ),
                  )
                else
                  Text(
                    _stripHtmlIfNeeded(coinDetail.description),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // Grafik Çizici
  Widget _buildChart(List<List<dynamic>> chartData) {
    if (chartData.isEmpty) return const SizedBox();

    final List<FlSpot> spots = chartData.map((point) {
      return FlSpot(
        (point[0] as int).toDouble(),
        (point[1] as num).toDouble(),
      );
    }).toList();

    final Color chartColor = (spots.last.y >= spots.first.y)
        ? const Color(0xFF00B050)
        : Colors.redAccent;

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final DateTime date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  "₺${spot.y.toStringAsFixed(2)}\n",
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "${date.day}/${date.month}",
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: chartColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [chartColor.withOpacity(0.3), chartColor.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtmlIfNeeded(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
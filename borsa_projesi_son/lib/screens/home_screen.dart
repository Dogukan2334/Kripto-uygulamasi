import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Cache temizlemek için
import '../models/coin_model.dart';
import '../services/api_services.dart';
import 'coin_detail_screen.dart';
import '../widgets/skeleton.dart'; // İskelet widget'ı

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  // Veri listeleri
  List<CoinModel> _allCoins = [];
  List<CoinModel> _filteredCoins = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Arama kontrolcüsü
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCoins(); // Ekran açılınca verileri çek
  }

  // Verileri Çekme Fonksiyonu
  Future<void> _loadCoins() async {
    // Ekran kapanmışsa işlem yapma
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final coins = await _apiService.fetchCoins();

      // Veri geldiğinde ekran hala açık mı kontrol et (HATA BURADAN ÇIKIYORDU)
      if (!mounted) return;

      setState(() {
        _allCoins = coins;
        _filteredCoins = coins;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Hata durumunda da kontrol et

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Çek-Yenile Fonksiyonu
  Future<void> _refreshCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('coins_cache');
    await prefs.remove('coins_cache_time');

    // Tekrar yükle
    if (mounted) {
      await _loadCoins();
    }
  }

  // Arama Fonksiyonu
  void _runFilter(String enteredKeyword) {
    List<CoinModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allCoins;
    } else {
      results = _allCoins
          .where((coin) =>
      coin.name.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          coin.symbol.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredCoins = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // 1. ARAMA ÇUBUĞU
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFF00B050),
              decoration: InputDecoration(
                hintText: 'Coin Ara (Örn: Bitcoin, BTC)...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00B050)),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF00B050), width: 1),
                ),
              ),
            ),
          ),

          // 2. LİSTE ALANI
          Expanded(
            child: _isLoading
            // Yüklenirken İskelet Göster
                ? ListView.builder(
              padding: const EdgeInsets.only(top: 0),
              itemCount: 10,
              itemBuilder: (context, index) => const CoinSkeleton(),
            )
                : _errorMessage.isNotEmpty
            // Hata Durumu
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.redAccent[100]),
                  const SizedBox(height: 10),
                  Text(
                    "Bir Hata Oluştu!",
                    style: TextStyle(color: Colors.redAccent[100], fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadCoins,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Tekrar Dene", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B050),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                ],
              ),
            )
                : _filteredCoins.isEmpty
            // Arama Sonucu Boşsa
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[700]),
                  const SizedBox(height: 10),
                  const Text("Sonuç bulunamadı.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
            // Liste
                : RefreshIndicator(
              onRefresh: _refreshCoins,
              color: const Color(0xFF00B050),
              backgroundColor: const Color(0xFF2C2C2C),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _filteredCoins.length,
                itemBuilder: (context, index) {
                  final coin = _filteredCoins[index];
                  return _buildCoinCard(coin);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Coin Kartı
  Widget _buildCoinCard(CoinModel coin) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoinDetailScreen(coinId: coin.id),
          ),
        );
      },
      splashColor: const Color(0xFF00B050).withOpacity(0.3),
      highlightColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Card(
          color: const Color(0xFF2C2C2C),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Logo
                Image.network(
                  coin.image,
                  height: 40,
                  width: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.currency_bitcoin, size: 40, color: Colors.grey);
                  },
                ),
                const SizedBox(width: 12),

                // İsim ve Sembol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coin.symbol.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Fiyat ve Değişim
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₺${coin.currentPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildPriceChange(coin.priceChangePercentage24h),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Yüzdelik Değişim Kutusu
  Widget _buildPriceChange(double percentChange) {
    final Color color = percentChange >= 0 ? const Color(0xFF00B050) : Colors.redAccent;
    final String sign = percentChange >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        "$sign${percentChange.toStringAsFixed(2)}%",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
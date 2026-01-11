import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../services/api_services.dart';
import 'coin_detail_screen.dart';

class PiyasaScreen extends StatefulWidget {
  const PiyasaScreen({super.key});

  @override
  State<PiyasaScreen> createState() => _PiyasaScreenState();
}

class _PiyasaScreenState extends State<PiyasaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  late Future<List<CoinModel>> _marketFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _marketFuture = _apiService.fetchCoins();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TAB BAR (Yükselenler / Düşenler)
        TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00B050),
          labelColor: const Color(0xFF00B050),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'En Çok Yükselenler'),
            Tab(text: 'En Çok Düşenler'),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<CoinModel>>(
            future: _marketFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00B050)));
              }
              if (snapshot.hasError) return const Center(child: Text("Veri alınamadı", style: TextStyle(color: Colors.white)));

              if (snapshot.hasData) {
                // Veriyi sıralama işlemi
                var allCoins = snapshot.data!;

                // Yükselenler (Büyükten küçüğe)
                var gainers = List<CoinModel>.from(allCoins);
                gainers.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));

                // Düşenler (Küçükten büyüğe)
                var losers = List<CoinModel>.from(allCoins);
                losers.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(gainers.take(20).toList()), // İlk 20
                    _buildList(losers.take(20).toList()),  // İlk 20
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<CoinModel> coins) {
    return ListView.builder(
      itemCount: coins.length,
      itemBuilder: (context, index) {
        final coin = coins[index];
        final isPositive = coin.priceChangePercentage24h >= 0;

        return ListTile(
          leading: Image.network(coin.image, width: 30, errorBuilder: (_,__,___)=>const Icon(Icons.error)),
          title: Text(coin.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(coin.symbol.toUpperCase(), style: TextStyle(color: Colors.grey[400])),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isPositive ? const Color(0xFF00B050) : Colors.redAccent).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "%${coin.priceChangePercentage24h.toStringAsFixed(2)}",
              style: TextStyle(
                color: isPositive ? const Color(0xFF00B050) : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CoinDetailScreen(coinId: coin.id)));
          },
        );
      },
    );
  }
}
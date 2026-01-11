import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../services/api_services.dart';
import 'coin_detail_screen.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<CoinModel>> _trendFuture;

  @override
  void initState() {
    super.initState();
    _trendFuture = _apiService.fetchTrending();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "🔥 Dünya Geneli Trend Aramalar",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<CoinModel>>(
            future: _trendFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00B050)));
              }
              if (snapshot.hasError) return const Center(child: Text("Trend verisi yok", style: TextStyle(color: Colors.grey)));

              final trends = snapshot.data!;

              return ListView.builder(
                itemCount: trends.length,
                itemBuilder: (context, index) {
                  final coin = trends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.network(coin.image),
                    ),
                    title: Text(coin.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(coin.symbol, style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CoinDetailScreen(coinId: coin.id)));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
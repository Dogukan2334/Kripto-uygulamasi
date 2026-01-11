class CoinModel {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;

  CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
  });

  // Bu 'factory' metodu, API'den gelen JSON'ı
  // bizim CoinModel nesnemize dönüştürmek için kullanılır.
  factory CoinModel.fromJson(Map<String, dynamic> json) {
    // API'den gelen verilerin 'null' (boş) gelme ihtimaline karşı
    // küçük bir kontrol ekleyelim.
    return CoinModel(
      id: json['id'] as String? ?? 'bilinmiyor',
      symbol: json['symbol'] as String? ?? '?',
      name: json['name'] as String? ?? 'Bilinmeyen Coin',
      image: json['image'] as String? ?? '',
      currentPrice: (json['current_price'] as num? ?? 0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] as num? ?? 0).toDouble(),
    );
  }
}
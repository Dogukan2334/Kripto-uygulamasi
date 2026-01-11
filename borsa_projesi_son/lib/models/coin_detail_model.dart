class CoinDetailModel {
  final String id;
  final String name;
  final String largeImage;
  final String description;

  CoinDetailModel({
    required this.id,
    required this.name,
    required this.largeImage,
    required this.description,
  });

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    return CoinDetailModel(
      id: json['id'] as String? ?? 'bilinmiyor',
      name: json['name'] as String? ?? 'Bilinmeyen Coin',
      largeImage: json['image']['large'] as String? ?? '',
      description: json['description']['en'] as String? ?? 'Açıklama yok.',
    );
  }
}
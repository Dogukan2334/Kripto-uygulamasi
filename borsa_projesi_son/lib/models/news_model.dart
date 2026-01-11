class NewsModel {
  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final String source;
  final String url;

  NewsModel({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.source,
    required this.url,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Başlık Yok',
      body: json['body'] ?? '',
      imageUrl: json['imageurl'] ?? '',
      source: json['source_info']['name'] ?? 'Kaynak',
      url: json['url'] ?? '',
    );
  }
}
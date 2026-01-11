import 'package:flutter/material.dart';

class KurumlarScreen extends StatelessWidget {
  const KurumlarScreen({super.key});

  final List<Map<String, String>> kurumlar = const [
    {'name': 'BtcTurk', 'type': 'Kripto Borsa', 'desc': 'Türkiye\'nin ilk Bitcoin alım satım platformu.'},
    {'name': 'Paribu', 'type': 'Kripto Borsa', 'desc': 'Yüksek hacimli yerli kripto para borsası.'},
    {'name': 'Binance TR', 'type': 'Global/Yerel', 'desc': 'Dünya devinin Türkiye yapılanması.'},
    {'name': 'Midas', 'type': 'Borsa/Hisse', 'desc': 'Amerikan ve Türk borsalarına erişim.'},
    {'name': 'Garanti BBVA', 'type': 'Banka', 'desc': 'Bankacılık ve yatırım hizmetleri.'},
    {'name': 'İş Bankası', 'type': 'Banka', 'desc': 'İşCep üzerinden yatırım imkanı.'},
    {'name': 'Yapı Kredi', 'type': 'Banka', 'desc': 'Yatırım dünyam ile borsa işlemleri.'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: kurumlar.length,
      itemBuilder: (context, index) {
        final k = kurumlar[index];
        return Card(
          color: const Color(0xFF2C2C2C),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B050).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business, color: Color(0xFF00B050)),
            ),
            title: Text(k['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(k['type']!, style: const TextStyle(color: Color(0xFF00B050), fontSize: 12, fontWeight: FontWeight.bold)),
                Text(k['desc']!, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
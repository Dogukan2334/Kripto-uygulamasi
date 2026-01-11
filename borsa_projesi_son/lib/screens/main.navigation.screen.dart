import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Kullanıcı bilgisi için
import '../services/auth_service.dart'; // Çıkış işlemi için
import 'home_screen.dart';
import 'piyasa_screen.dart';
import 'haberler_screen.dart';
import 'radar_screen.dart';
import 'kurumlar_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _seciliIndex = 0;
  final AuthService _authService = AuthService(); // Çıkış servisimizi çağırdık

  // 5 sekmeye uygun ekran listesi
  static const List<Widget> _ekranSecenekleri = <Widget>[
    HomeScreen(),
    PiyasaScreen(),
    HaberlerScreen(),
    RadarScreen(),
    KurumlarScreen(),
  ];

  // Başlık listesi
  static const List<String> _baslikSecenekleri = <String>[
    'Piyasalar',
    'Piyasa Gündemi',
    'Haberler',
    'Radar (Favorilerim)',
    'Kurumlar',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _seciliIndex = index;
    });
  }

  // YENİ: Profil Menüsünü Açan Fonksiyon
  void _showProfileMenu() {
    // Şu anki kullanıcıyı al
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C), // Koyu tema arka plan
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
            children: [
              // Gri bir tutamaç çizgisi (Görsel detay)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Icon(Icons.account_circle, size: 70, color: Color(0xFF00B050)),
              const SizedBox(height: 16),

              const Text(
                "Hesabım",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
              const SizedBox(height: 8),

              // Kullanıcının E-postası
              Text(
                user?.email ?? 'Kullanıcı',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 30),

              // Çıkış Yap Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // Menüyü kapat
                    await _authService.signOut(); // Çıkış yap
                    // main.dart'taki yapı sayesinde otomatik Login ekranına dönecek
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.white, fontSize: 16)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_baslikSecenekleri[_seciliIndex]),
        // YENİ: Sağ üst köşeye profil ikonu ekledik
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _showProfileMenu, // Tıklanınca menüyü aç
          ),
          const SizedBox(width: 8), // Biraz sağdan boşluk
        ],
      ),
      body: Center(
        child: _ekranSecenekleri.elementAt(_seciliIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Piyasalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Piyasa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Haberler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Radar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Kurumlar',
          ),
        ],
        currentIndex: _seciliIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF2C2C2C),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
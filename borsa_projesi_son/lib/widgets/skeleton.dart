import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CoinSkeleton extends StatelessWidget {
  const CoinSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!, // Koyu gri (Başlangıç rengi)
        highlightColor: Colors.grey[700]!, // Açık gri (Parlayan renk)
        child: Card(
          color: const Color(0xFF2C2C2C),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 1. Yuvarlak Logo Yeri
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // 2. İsim ve Sembol Yeri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 50,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // 3. Fiyat ve Değişim Yeri
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
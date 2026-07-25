import 'package:flutter/material.dart';

void main() {
  runApp(const OtelBulApp());
}

class OtelBulApp extends StatelessWidget {
  const OtelBulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otel Bul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1D6B8C),
        scaffoldBackgroundColor: const Color(0xFFF6F2E9),
      ),
      home: const SearchScreen(),
    );
  }
}

class Hotel {
  final String name;
  final String area;
  final double rating;
  final int price;
  const Hotel(this.name, this.area, this.rating, this.price);
}

final Map<String, List<Hotel>> hotelsByCity = {
  'İstanbul': [
    Hotel('Boğaz Konak Otel', 'Beşiktaş', 4.7, 3200),
    Hotel('Sultanahmet Butik', 'Fatih', 4.4, 2450),
    Hotel('Kadıköy Loft', 'Kadıköy', 4.2, 1980),
    Hotel('Taksim City Suites', 'Beyoğlu', 4.0, 2100),
  ],
  'Antalya': [
    Hotel('Liman Butik Otel', 'Konyaaltı', 4.6, 2150),
    Hotel('Kaleiçi Konak Otel', 'Kaleiçi', 4.3, 2640),
    Hotel('Lara Sahil Resort', 'Lara', 4.8, 3920),
    Hotel('Side Antik Pansiyon', 'Side', 4.1, 1750),
  ],
  'Bodrum': [
    Hotel('Gümbet Marina Otel', 'Gümbet', 4.5, 3100),
    Hotel('Bitez Zeytinlik Ev', 'Bitez', 4.3, 2300),
    Hotel('Yalıkavak Beyaz Konak', 'Yalıkavak', 4.9, 5400),
  ],
  'Kapadokya': [
    Hotel('Mağara Ev Göreme', 'Göreme', 4.8, 2900),
    Hotel('Ürgüp Taş Konak', 'Ürgüp', 4.4, 1900),
    Hotel('Uçhisar Kaya Otel', 'Uçhisar', 4.6, 2600),
  ],
};

({String label, Color bg, Color fg}) priceStatus(int price, double avg) {
  final diff = ((price - avg) / avg) * 100;
  if (diff <= -10) {
    return (label: '%${(-diff).round()} uygun', bg: const Color(0xFFEAF1E3), fg: const Color(0xFF4C6B34));
  } else if (diff >= 10) {
    return (label: '%${diff.round()} pahalı', bg: const Color(0xFFF6E6E1), fg: const Color(0xFFA6432D));
  }
  return (label: 'Bölge ortalaması', bg: const Color(0xFFF7EEDD), fg: const Color(0xFF966A22));
}

// ---------- EKRAN 1: Arama ----------

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cities = hotelsByCity.keys.toList();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nereye gidiyorsun?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              const Text('Şehir seç', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: ListTile(
                        title: Text(city),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ListScreen(city: city)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- EKRAN 2: Sonuç listesi ----------

class ListScreen extends StatelessWidget {
  final String city;
  const ListScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    final hotels = List<Hotel>.from(hotelsByCity[city]!)..sort((a, b) => a.price.compareTo(b.price));
    final avg = hotels.map((h) => h.price).reduce((a, b) => a + b) / hotels.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0,
        title: Text(city, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${hotels.length} otel · bölge ortalaması ₺${avg.round()}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: hotels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  final status = priceStatus(hotel.price, avg);

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DetailScreen(city: city, hotel: hotel, hotels: hotels)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70,
                            decoration: BoxDecoration(color: const Color(0xFFEFEAE0), borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(height: 8),
                          Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('★ ${hotel.rating} · ${hotel.area}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('₺${hotel.price}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: status.bg, borderRadius: BorderRadius.circular(6)),
                                child: Text(status.label, style: TextStyle(color: status.fg, fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- EKRAN 3: Otel detayı ----------

class DetailScreen extends StatelessWidget {
  final String city;
  final Hotel hotel;
  final List<Hotel> hotels;
  const DetailScreen({super.key, required this.city, required this.hotel, required this.hotels});

  @override
  Widget build(BuildContext context) {
    final avg = hotels.map((h) => h.price).reduce((a, b) => a + b) / hotels.length;
    final minP = hotels.map((h) => h.price).reduce((a, b) => a < b ? a : b);
    final maxP = hotels.map((h) => h.price).reduce((a, b) => a > b ? a : b);
    final status = priceStatus(hotel.price, avg);
    final fraction = maxP == minP ? 0.5 : (hotel.price - minP) / (maxP - minP);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(color: const Color(0xFFEFEAE0), borderRadius: BorderRadius.circular(14)),
            ),
            const SizedBox(height: 14),
            Text(hotel.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('★ ${hotel.rating} · ${hotel.area}, $city', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Text('₺${hotel.price} / gece', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${status.label} · bölge ortalamasına göre', style: TextStyle(color: status.fg)),
            const SizedBox(height: 24),
            Stack(
              children: [
                Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFEFEAE0), borderRadius: BorderRadius.circular(3))),
                Positioned(
                  left: fraction * (MediaQuery.of(context).size.width - 40) - 1,
                  top: -5,
                  child: Container(width: 2, height: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₺$minP en düşük', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text('₺${avg.round()} ortalama', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text('₺$maxP en yüksek', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
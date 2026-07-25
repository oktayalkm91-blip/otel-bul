import 'package:flutter/material.dart';

void main() {
  runApp(const OtelBulApp());
}

final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

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
  final String city;
  const Hotel(this.name, this.area, this.rating, this.price, this.city);
}

final Map<String, List<Hotel>> hotelsByCity = {
  'İstanbul': [
    Hotel('Boğaz Konak Otel', 'Beşiktaş', 4.7, 3200, 'İstanbul'),
    Hotel('Sultanahmet Butik', 'Fatih', 4.4, 2450, 'İstanbul'),
    Hotel('Kadıköy Loft', 'Kadıköy', 4.2, 1980, 'İstanbul'),
    Hotel('Taksim City Suites', 'Beyoğlu', 4.0, 2100, 'İstanbul'),
    Hotel('Üsküdar Sahil Otel', 'Üsküdar', 4.3, 2250, 'İstanbul'),
    Hotel('Şişli İş Oteli', 'Şişli', 3.9, 1850, 'İstanbul'),
  ],
  'Antalya': [
    Hotel('Liman Butik Otel', 'Konyaaltı', 4.6, 2150, 'Antalya'),
    Hotel('Kaleiçi Konak Otel', 'Kaleiçi', 4.3, 2640, 'Antalya'),
    Hotel('Lara Sahil Resort', 'Lara', 4.8, 3920, 'Antalya'),
    Hotel('Side Antik Pansiyon', 'Side', 4.1, 1750, 'Antalya'),
    Hotel('Belek Golf Resort', 'Belek', 4.7, 4200, 'Antalya'),
    Hotel('Kemer Çam Ev', 'Kemer', 4.2, 2050, 'Antalya'),
  ],
  'Bodrum': [
    Hotel('Gümbet Marina Otel', 'Gümbet', 4.5, 3100, 'Bodrum'),
    Hotel('Bitez Zeytinlik Ev', 'Bitez', 4.3, 2300, 'Bodrum'),
    Hotel('Yalıkavak Beyaz Konak', 'Yalıkavak', 4.9, 5400, 'Bodrum'),
    Hotel('Turgutreis Sahil Pansiyon', 'Turgutreis', 4.0, 1900, 'Bodrum'),
  ],
  'Kapadokya': [
    Hotel('Mağara Ev Göreme', 'Göreme', 4.8, 2900, 'Kapadokya'),
    Hotel('Ürgüp Taş Konak', 'Ürgüp', 4.4, 1900, 'Kapadokya'),
    Hotel('Uçhisar Kaya Otel', 'Uçhisar', 4.6, 2600, 'Kapadokya'),
    Hotel('Avanos Çömlek Ev', 'Avanos', 4.1, 1700, 'Kapadokya'),
  ],
};

enum PriceTier { hepsi, uygun, ortalama, pahali }
enum SortBy { fiyat, puan }

({String label, Color bg, Color fg, PriceTier tier}) priceStatus(int price, double avg) {
  final diff = ((price - avg) / avg) * 100;
  if (diff <= -10) {
    return (label: '%${(-diff).round()} uygun', bg: const Color(0xFFEAF1E3), fg: const Color(0xFF4C6B34), tier: PriceTier.uygun);
  } else if (diff >= 10) {
    return (label: '%${diff.round()} pahalı', bg: const Color(0xFFF6E6E1), fg: const Color(0xFFA6432D), tier: PriceTier.pahali);
  }
  return (label: 'Bölge ortalaması', bg: const Color(0xFFF7EEDD), fg: const Color(0xFF966A22), tier: PriceTier.ortalama);
}

Widget favoriteButton(Hotel hotel) {
  return ValueListenableBuilder<Set<String>>(
    valueListenable: favorites,
    builder: (context, favSet, _) {
      final isFav = favSet.contains(hotel.name);
      return IconButton(
        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? const Color(0xFFA6432D) : Colors.grey, size: 20),
        onPressed: () {
          final updated = Set<String>.from(favSet);
          if (isFav) {
            updated.remove(hotel.name);
          } else {
            updated.add(hotel.name);
          }
          favorites.value = updated;
        },
      );
    },
  );
}

// ---------- EKRAN 1: Arama ----------

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final cities = hotelsByCity.keys.where((c) => c.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Nereye gidiyorsun?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Color(0xFFA6432D)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  hintText: 'Şehir ara (örn. Antalya)',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Şehir seç', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Expanded(
                child: cities.isEmpty
                    ? const Center(child: Text('Şehir bulunamadı', style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
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

class ListScreen extends StatefulWidget {
  final String city;
  const ListScreen({super.key, required this.city});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  PriceTier selectedTier = PriceTier.hepsi;
  SortBy sortBy = SortBy.fiyat;

  @override
  Widget build(BuildContext context) {
    final baseHotels = List<Hotel>.from(hotelsByCity[widget.city]!);
    final avg = baseHotels.map((h) => h.price).reduce((a, b) => a + b) / baseHotels.length;

    var hotels = selectedTier == PriceTier.hepsi
        ? baseHotels
        : baseHotels.where((h) => priceStatus(h.price, avg).tier == selectedTier).toList();

    hotels.sort((a, b) => sortBy == SortBy.fiyat
        ? a.price.compareTo(b.price)
        : b.rating.compareTo(a.rating));

    Widget chip(String label, PriceTier tier) {
      final selected = selectedTier == tier;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => selectedTier = tier),
          selectedColor: const Color(0xFF1D6B8C),
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black12),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0,
        title: Text(widget.city, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${baseHotels.length} otel · bölge ortalaması ₺${avg.round()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                DropdownButton<SortBy>(
                  value: sortBy,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  items: const [
                    DropdownMenuItem(value: SortBy.fiyat, child: Text('Fiyata göre')),
                    DropdownMenuItem(value: SortBy.puan, child: Text('Puana göre')),
                  ],
                  onChanged: (value) => setState(() => sortBy = value!),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  chip('Tümü', PriceTier.hepsi),
                  chip('Uygun', PriceTier.uygun),
                  chip('Ortalama', PriceTier.ortalama),
                  chip('Pahalı', PriceTier.pahali),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: hotels.isEmpty
                  ? const Center(child: Text('Bu filtrede otel yok', style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: hotels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        final status = priceStatus(hotel.price, avg);

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => DetailScreen(hotel: hotel, hotels: baseHotels)),
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
                                Stack(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: double.infinity,
                                      decoration: BoxDecoration(color: const Color(0xFFEFEAE0), borderRadius: BorderRadius.circular(10)),
                                    ),
                                    Positioned(right: 0, top: -8, child: favoriteButton(hotel)),
                                  ],
                                ),
                                const SizedBox(height: 4),
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
  final Hotel hotel;
  final List<Hotel> hotels;
  const DetailScreen({super.key, required this.hotel, required this.hotels});

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
        actions: [favoriteButton(hotel)],
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
            Text('★ ${hotel.rating} · ${hotel.area}, ${hotel.city}', style: const TextStyle(color: Colors.grey)),
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

// ---------- EKRAN 4: Favoriler ----------

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allHotels = hotelsByCity.values.expand((list) => list).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0,
        title: const Text('Favorilerim', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: favorites,
        builder: (context, favSet, _) {
          final favHotels = allHotels.where((h) => favSet.contains(h.name)).toList();
          if (favHotels.isEmpty) {
            return const Center(child: Text('Henüz favori otelin yok', style: TextStyle(color: Colors.grey)));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              itemCount: favHotels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final hotel = favHotels[index];
                final cityHotels = hotelsByCity[hotel.city]!;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DetailScreen(hotel: hotel, hotels: cityHotels)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('${hotel.area}, ${hotel.city} · ₺${hotel.price}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        favoriteButton(hotel),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const WallpapersApp());
}

class WallpapersApp extends StatelessWidget {
  const WallpapersApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallpapers 4K HD',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;

  // لائحة صور 4K أونلاين 100% - تقدر تزيد عليها
  final List<String> wallpapers = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1080',
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=1080',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1080',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1080',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=1080',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=1080',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1080',
  ];

  @override
  void initState() {
    super.initState();
    loadBanner();
    loadInterstitial();
  }

  void loadBanner() {
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // test id
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();
  }

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // test id
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => interstitialAd = ad,
        onAdFailedToLoad: (err) => interstitialAd = null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallpapers 4K HD'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.6, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DetailScreen(imageUrl: wallpapers[index], interstitialAd: interstitialAd),
                    ));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(imageUrl: wallpapers[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          if (bannerAd != null)
            SizedBox(height: bannerAd!.size.height.toDouble(), child: AdWidget(ad: bannerAd!)),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String imageUrl;
  final InterstitialAd? interstitialAd;
  const DetailScreen({super.key, required this.imageUrl, this.interstitialAd});

  Future<void> setWallpaper(BuildContext context) async {
    try {
      if (interstitialAd != null) {
        interstitialAd!.show();
      }
      bool result = await WallpaperManagerFlutter().setWallpaper(imageUrl, WallpaperManagerFlutter.homeScreen);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ? 'تم تعيين الخلفية ✅' : 'فشل ❌')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Row(
              children: [
                Expanded(child: ElevatedButton.icon(onPressed: () => Share.share(imageUrl), icon: const Icon(Icons.share), label: const Text('Share'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(onPressed: () => setWallpaper(context), icon: const Icon(Icons.wallpaper), label: const Text('Set'))),
              ],
            ),
          ),
          Positioned(top: 40, left: 10, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }
}

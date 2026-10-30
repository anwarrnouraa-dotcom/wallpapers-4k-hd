import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:share_plus/share_plus.dart';

void main() { runApp(MyApp()); }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'Wallpapers 4K HD', home: WallpaperHome());
  }
}

class WallpaperHome extends StatefulWidget {
  @override
  _WallpaperHomeState createState() => _WallpaperHomeState();
}

class _WallpaperHomeState extends State<WallpaperHome> {
  final List<String> wallpapers = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wallpapers 4K HD - Online'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      backgroundColor: Colors.black,
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: wallpapers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewScreen(imageUrl: wallpapers[index]))),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: wallpapers[index], fit: BoxFit.cover, placeholder: (c,s)=>Center(child:CircularProgressIndicator()), errorWidget: (c,s,e)=>Icon(Icons.error, color: Colors.white))),
          );
        },
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final String imageUrl;
  PreviewScreen({required this.imageUrl});
  Future<void> _setWallpaper(BuildContext context) async {
    try {
      await WallpaperManagerFlutter().setWallpaper(imageUrl, WallpaperManagerFlutter.HOME_SCREEN);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallpaper applied!')));
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Center(child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain)),
        Positioned(top: 40, left: 10, child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: ()=>Navigator.pop(context))),
        Positioned(bottom: 30, left: 20, right: 20, child: Row(children: [Expanded(child: ElevatedButton(onPressed: ()=>_setWallpaper(context), child: Text('Set Wallpaper'))), SizedBox(width: 10), IconButton(onPressed: ()=>Share.share(imageUrl), icon: Icon(Icons.share, color: Colors.white))]))
      ]),
    );
  }
}

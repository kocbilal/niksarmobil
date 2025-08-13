import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NiksarMobilApp());
}

class NiksarMobilApp extends StatelessWidget {
  const NiksarMobilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niksar Mobil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BF80)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      ),
      home: const SplashGate(child: RootShell()),
    );
  }
}

/// Basit splash
class SplashGate extends StatefulWidget {
  final Widget child;
  const SplashGate({super.key, required this.child});
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: _ready
          ? widget.child
          : Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BF80), Color(0xFF00A874)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Niksar Mobil',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              SizedBox(height: 16),
              CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

enum BottomItem { home, kesfet, cekGonder, nobetci, ayarlar }

class _RootShellState extends State<RootShell> with SingleTickerProviderStateMixin {
  // IndexedStack aktif sayfa
  int _stackIndex = 0;

  // --- Stack indexleri (sabit)
  static const int idxHome = 0;
  static const int idxKesfet = 1;
  static const int idxDummy = 2;
  static const int idxNobetci = 3;
  static const int idxSettings = 4;
  static const int idxUlasim = 5;
  static const int idxBelediyem = 6;
  static const int idxEtkinlikler = 7;
  static const int idxOdeme = 8;
  static const int idxRehber = 9;
  static const int idxSearch = 10;

  // WebView key’leri
  final _keyKesfet = GlobalKey<_WebTabState>();
  final _keyNobetci = GlobalKey<_WebTabState>();
  final _keyUlasim = GlobalKey<_WebTabState>();
  final _keyBelediyem = GlobalKey<_WebTabState>();
  final _keyEtkinlikler = GlobalKey<_WebTabState>();
  final _keyOdeme = GlobalKey<_WebTabState>();
  final _keyRehber = GlobalKey<_WebTabState>();
  final _keySearch = GlobalKey<_WebTabState>();

  late final AnimationController _fadeCtrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 140));

  @override
  void initState() {
    super.initState();
    _ensureLocationPermission();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureLocationPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _fadePulse() async {
    try {
      await _fadeCtrl.forward();
      await _fadeCtrl.reverse();
    } catch (_) {}
  }

  BottomItem? _currentBottom() {
    switch (_stackIndex) {
      case idxHome:     return BottomItem.home;
      case idxKesfet:   return BottomItem.kesfet;
      case idxDummy:    return BottomItem.cekGonder;
      case idxNobetci:  return BottomItem.nobetci;
      case idxSettings: return BottomItem.ayarlar;
      default:          return null; // Ulaşım/Belediyem/Etkinlikler/Ödeme/Rehber/Search
    }
  }

  void _selectBottom(BottomItem item) {
    switch (item) {
      case BottomItem.home:      _stackIndex = idxHome; break;
      case BottomItem.kesfet:    _stackIndex = idxKesfet; break;
      case BottomItem.cekGonder: _stackIndex = idxDummy; break; // WhatsApp dışa açılacak
      case BottomItem.nobetci:   _stackIndex = idxNobetci; break;
      case BottomItem.ayarlar:   _stackIndex = idxSettings; break;
    }
    setState(() {});
    _fadePulse();
  }

  // Anasayfa kısayolları → ilgili hazır WebView’e git (alt menüde seçim YOK)
  void _openShortcut(String url) {
    final u = Uri.tryParse(url);
    final path = (u?.path ?? '').toLowerCase();

    if (path.contains('nobetci-eczaneler')) {
      _stackIndex = idxNobetci;
    } else if (path.contains('kesfet')) {
      _stackIndex = idxKesfet;
    } else if (path.contains('ulasim')) {
      _stackIndex = idxUlasim;
    } else if (path.contains('belediyem')) {
      _stackIndex = idxBelediyem;
    } else if (path.contains('etkinlikler')) {
      _stackIndex = idxEtkinlikler;
    } else if (path.contains('odeme')) {
      _stackIndex = idxOdeme;
    } else if (path.contains('rehber')) {
      _stackIndex = idxRehber;
    } else {
      _stackIndex = idxKesfet;
    }
    setState(() {});
    _fadePulse();
  }

  // Arama → Search WebView’i önce yükle sonra göster
  Future<void> _openSearch(String query) async {
    final url = 'https://niksarmobil.tr/?s=$query';
    await _keySearch.currentState?.loadUrlAndWait(url);
    setState(() => _stackIndex = idxSearch);
    _fadePulse();
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/905018050060?text=Merhaba%2C%20Niksar%20Mobil%27den%20yaz%C4%B1yorum.');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeNativePage(onShortcut: _openShortcut, onSearch: _openSearch),
      WebTab(key: _keyKesfet, initialUrl: 'https://niksarmobil.tr/kesfet'),
      const _DummyPage(), // Çek Gönder dışa açılıyor
      WebTab(key: _keyNobetci, initialUrl: 'https://niksarmobil.tr/nobetci-eczaneler'),
      const SettingsPage(),
      WebTab(key: _keyUlasim, initialUrl: 'https://niksarmobil.tr/ulasim'),
      WebTab(key: _keyBelediyem, initialUrl: 'https://niksarmobil.tr/belediyem'),
      WebTab(key: _keyEtkinlikler, initialUrl: 'https://niksarmobil.tr/etkinlikler'),
      WebTab(key: _keyOdeme, initialUrl: 'https://niksarmobil.tr/odeme'),
      WebTab(key: _keyRehber, initialUrl: 'https://niksarmobil.tr/rehber'),
      WebTab(key: _keySearch, initialUrl: 'about:blank'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _stackIndex, children: pages),
          IgnorePointer(
            ignoring: true,
            child: FadeTransition(
              opacity: _fadeCtrl.drive(Tween(begin: 0.0, end: 0.06)),
              child: const ColoredBox(color: Colors.black),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        selected: _currentBottom(),
        onTap: (item) async {
          if (item == BottomItem.cekGonder) {
            await _openWhatsApp();
            return;
          }
          _selectBottom(item);
        },
      ),
    );
  }
}

/// Web sekmesi + iOS için erken geolocation enjeksiyonu + sol kenardan geri kaydırma
class WebTab extends StatefulWidget {
  final String initialUrl;
  const WebTab({super.key, required this.initialUrl});
  @override
  State<WebTab> createState() => _WebTabState();
}

class _WebTabState extends State<WebTab> with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;
  int _progress = 0;
  Completer<void>? _navStarted;

  // geolocation watch abonelikleri
  final Map<String, StreamSubscription<Position>> _watchSubs = {};
  bool _polyfillInjected = false;

  // iOS sol kenar geri kaydırma (basit eşik)
  double _dragDx = 0;

  Future<void> loadUrlAndWait(String url) {
    _navStarted ??= Completer<void>();
    _controller.loadRequest(Uri.parse(url));
    return _navStarted!.future.timeout(const Duration(seconds: 2), onTimeout: () {});
  }

  void loadUrl(String url) => _controller.loadRequest(Uri.parse(url));

  @override
  void dispose() {
    for (final s in _watchSubs.values) {
      s.cancel();
    }
    _watchSubs.clear();
    super.dispose();
  }

  // --- Geolocation polyfill (JS)
  static const _geoPolyfill = r'''
(function(){
  if (window.__nativeGeoPolyfilled) return;
  window.__nativeGeoPolyfilled = true;

  window.__nativeGeo = { onceCb: null, watchers: {} };

  window.__nativeGeo_receiveOnce = function(lat, lon, acc) {
    try { if (window.__nativeGeo.onceCb && window.__nativeGeo.onceCb.success) {
      window.__nativeGeo.onceCb.success({ coords: { latitude: lat, longitude: lon, accuracy: acc } });
      window.__nativeGeo.onceCb = null;
    }} catch(e){}
  };

  window.__nativeGeo_receiveWatch = function(id, lat, lon, acc) {
    try {
      var w = window.__nativeGeo.watchers[id];
      if (w && w.success) { w.success({ coords: { latitude: lat, longitude: lon, accuracy: acc } }); }
    } catch(e){}
  };

  var original = navigator.geolocation;

  navigator.geolocation.getCurrentPosition = function(success, error, options) {
    try {
      window.__nativeGeo.onceCb = { success: success, error: error };
      NativeGeo.postMessage(JSON.stringify({type:'getOnce'}));
    } catch(e) {
      if (original && original.getCurrentPosition) { return original.getCurrentPosition(success, error, options); }
    }
  };

  navigator.geolocation.watchPosition = function(success, error, options) {
    try {
      var id = Math.random().toString(36).slice(2);
      window.__nativeGeo.watchers[id] = { success: success, error: error };
      NativeGeo.postMessage(JSON.stringify({type:'watch', id:id}));
      return id;
    } catch(e) {
      if (original && original.watchPosition) { return original.watchPosition(success, error, options); }
    }
  };

  navigator.geolocation.clearWatch = function(id) {
    try {
      NativeGeo.postMessage(JSON.stringify({type:'clear', id:id}));
      delete window.__nativeGeo.watchers[id];
    } catch(e) {
      if (original && original.clearWatch) { return original.clearWatch(id); }
    }
  };
})();
''';

  Future<void> _injectGeoPolyfill({bool force = false}) async {
    if (_polyfillInjected && !force) return;
    try {
      await _controller.runJavaScript(_geoPolyfill);
      _polyfillInjected = true;
      // SPA/iframe gecikmeleri için küçük tekrarlar
      Future.delayed(const Duration(milliseconds: 300), () {
        _controller.runJavaScript(_geoPolyfill);
      });
      Future.delayed(const Duration(seconds: 1), () {
        _controller.runJavaScript(_geoPolyfill);
      });
    } catch (_) {}
  }

  // JS → Dart köprüsü
  Future<void> _onGeoMessage(JavaScriptMessage msg) async {
    try {
      final data = jsonDecode(msg.message) as Map<String, dynamic>;
      final type = data['type'] as String;

      if (type == 'getOnce') {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await _controller.runJavaScript(
          "window.__nativeGeo_receiveOnce(${pos.latitude},${pos.longitude},${pos.accuracy});",
        );
      } else if (type == 'watch') {
        final id = data['id'] as String;
        _watchSubs[id]?.cancel();
        final sub = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 3),
        ).listen((pos) {
          _controller.runJavaScript(
            "window.__nativeGeo_receiveWatch('$id',${pos.latitude},${pos.longitude},${pos.accuracy});",
          );
        });
        _watchSubs[id] = sub;
      } else if (type == 'clear') {
        final id = data['id'] as String;
        await _watchSubs[id]?.cancel();
        _watchSubs.remove(id);
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('NativeGeo', onMessageReceived: _onGeoMessage)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            // (Search preload için) sayfa başladı sinyali
            _navStarted?.complete();
            _navStarted = null;
            // iOS için erken polyfill
            _polyfillInjected = false;
            _injectGeoPolyfill(force: true);
          },
          onPageFinished: (_) {
            // SPA/iframe için tekrar
            _injectGeoPolyfill(force: true);
          },
          onProgress: (p) => setState(() => _progress = p),
          onNavigationRequest: (req) async {
            if (await _handleExternal(req.url)) return NavigationDecision.prevent;
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<bool> _handleExternal(String url) async {
    try {
      if (url.startsWith('intent://')) {
        final m = RegExp(r'S\.browser_fallback_url=([^;]+)').firstMatch(url);
        if (m != null) {
          final fb = Uri.decodeComponent(m.group(1)!);
          return await launchUrl(Uri.parse(fb), mode: LaunchMode.externalApplication);
        }
        final httpsUrl = url.replaceFirst('intent://', 'https://');
        return await launchUrl(Uri.parse(httpsUrl), mode: LaunchMode.externalApplication);
      }
      final uri = Uri.parse(url);
      final scheme = uri.scheme.toLowerCase();
      const ext = {'tel', 'sms', 'mailto', 'whatsapp', 'geo'};
      if (ext.contains(scheme)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      final h = uri.host.toLowerCase();
      final p = uri.path.toLowerCase();
      final isMap = h.contains('maps.app.goo.gl') ||
          (h.contains('goo.gl') && p.contains('/maps')) ||
          (h.contains('google.com') && p.contains('/maps')) ||
          (h.contains('yandex.') && p.contains('maps')) ||
          h.contains('waze.com');
      if (isMap) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // WebView + iOS kenar geri kaydırma overlay’i
    final webColumn = Column(
      children: [
        if (_progress < 100) LinearProgressIndicator(value: _progress / 100, minHeight: 3),
        Expanded(child: SafeArea(top: true, bottom: false, child: WebViewWidget(controller: _controller))),
      ],
    );

    return WillPopScope(
      onWillPop: _handleBack,
      child: Stack(
        children: [
          webColumn,
          if (Platform.isIOS)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 24, // sol kenar "geri" tutacağı
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (_) => _dragDx = 0,
                onHorizontalDragUpdate: (d) {
                  if (d.delta.dx > 0) _dragDx += d.delta.dx; // sağa doğru sürükleme
                },
                onHorizontalDragEnd: (_) async {
                  if (_dragDx > 60) {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                    }
                  }
                  _dragDx = 0;
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Anasayfa — butonlar önceden yüklenmiş tablara gider; arama Search tabına
class HomeNativePage extends StatelessWidget {
  final void Function(String url) onShortcut;
  final Future<void> Function(String encodedQuery) onSearch;
  const HomeNativePage({super.key, required this.onShortcut, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF00BF80);
    final searchCtrl = TextEditingController();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [green.withOpacity(0.95), green.withOpacity(0.75)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('28°  ☀️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const Positioned(
                    top: 56,
                    child: Text(
                      'Selam Bugün\nNasılsın?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.15),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
                      ),
                      child: TextField(
                        controller: searchCtrl,
                        onSubmitted: (v) {
                          final q = v.trim();
                          if (q.isNotEmpty) onSearch(Uri.encodeQueryComponent(q));
                        },
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Ara',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              final q = searchCtrl.text.trim();
                              if (q.isNotEmpty) onSearch(Uri.encodeQueryComponent(q));
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 18,
              children: [
                _Quick(icon: Icons.explore, label: 'Keşfet', url: 'https://niksarmobil.tr/kesfet', onTap: onShortcut),
                _Quick(icon: Icons.local_hospital, label: 'Nöbetçi\nEczane', url: 'https://niksarmobil.tr/nobetci-eczaneler', onTap: onShortcut),
                _Quick(icon: Icons.directions_bus, label: 'Ulaşım', url: 'https://niksarmobil.tr/ulasim', onTap: onShortcut),
                _Quick(icon: Icons.apartment, label: 'Belediyem', url: 'https://niksarmobil.tr/belediyem', onTap: onShortcut),
                _Quick(icon: Icons.event, label: 'Etkinlikler', url: 'https://niksarmobil.tr/etkinlikler', onTap: onShortcut),
                _Quick(icon: Icons.photo_camera, label: 'Çek Gönder', url: 'https://wa.me/905018050060', onTap: onShortcut),
                _Quick(icon: Icons.credit_card, label: 'Online\nÖdeme', url: 'https://niksarmobil.tr/odeme', onTap: onShortcut),
                _Quick(icon: Icons.call, label: 'Rehber', url: 'https://niksarmobil.tr/rehber', onTap: onShortcut),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final void Function(String url) onTap;
  const _Quick({required this.icon, required this.label, required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF00BF80);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => onTap(url),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: green, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2),
        ),
      ],
    );
  }
}

class _DummyPage extends StatelessWidget {
  const _DummyPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Ayarlar yakında', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
    );
  }
}

/// Alt menü – seçili olmayan durum destekli
class CustomBottomBar extends StatelessWidget {
  final BottomItem? selected;
  final void Function(BottomItem) onTap;
  const CustomBottomBar({super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color colorFor(BottomItem item) =>
        selected == item ? cs.primary : cs.onSurfaceVariant;

    Widget btn(BottomItem item, IconData icon, String label) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: colorFor(item)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: colorFor(item))),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            btn(BottomItem.home, Icons.home_outlined, 'Anasayfa'),
            btn(BottomItem.kesfet, Icons.explore_outlined, 'Keşfet'),
            btn(BottomItem.cekGonder, Icons.photo_camera_outlined, 'Çek Gönder'),
            btn(BottomItem.nobetci, Icons.local_hospital_outlined, 'Nöbetçi'),
            btn(BottomItem.ayarlar, Icons.settings_outlined, 'Ayarlar'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tubes_sparehub/deep_link_handler.dart';
import 'package:tubes_sparehub/services/user_session.dart';
import 'package:tubes_sparehub/pages/halaman_checkout.dart';
import 'package:tubes_sparehub/pages/halaman_profil/halaman_edit_profil.dart';
import 'package:tubes_sparehub/pages/homepage.dart';
import 'package:tubes_sparehub/pages/halaman_toko.dart';
import 'package:tubes_sparehub/pages/halaman_LoginAndRegister/login.dart';
import 'package:tubes_sparehub/pages/halaman_profil/halaman_saya.dart';
import 'package:tubes_sparehub/services/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Init deep link HANYA SEKALI di sini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkHandler.initDeepLinks(context);
    });
  }

  @override
  void dispose() {
    DeepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpareHub',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return MyHomePage(title: 'SpareHub', userData: userData);
        },
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.userData});
  final Map<String, dynamic>? userData;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  List<Widget> _pages = [];
  Map<String, dynamic>? _currentUserData;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.userData != null) {
      setState(() {
        _currentUserData = widget.userData;
        _isLoadingUserData = false;
      });
      _buildPages();
      return;
    }

    final userData = await UserSession.getUserData();
    setState(() {
      _currentUserData = userData;
      _isLoadingUserData = false;
    });
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      toko_saya(),
      const HomePage(),
      HalamanSaya(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => toko_saya()),
            );
          } else {
            _onItemTapped(index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Toko Saya"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Saya"),
        ],
      ),
    );
  }
}

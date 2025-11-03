import 'package:flutter/material.dart';
import 'package:tubes_sparehub/pages/halaman_profil/halaman_edit_profil.dart';
import 'package:tubes_sparehub/pages/homepage.dart';
import 'package:tubes_sparehub/pages/halaman_checkout.dart';
import 'package:tubes_sparehub/pages/halaman_toko.dart';
import 'package:tubes_sparehub/pages/halaman_LoginAndRegister/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      //home: const MyHomePage(title: 'SpareHub'),
      // home: CheckoutApp(),
      // home: ShopPage(),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;
  final List<Widget> _pages = [
    toko_saya(), // Toko Saya (halaman Rziqi)
    const HomePage(), // Home (grid produk)
    const EditProfil(), // Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(microseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Toko Saya"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Saya"),
        ],
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Text("Halaman Rziqi disini", style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

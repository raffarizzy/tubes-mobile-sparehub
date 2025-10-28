import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'SpareHub'),
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
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  List<Widget> _pages = [
    Page1(),
    Page2(),
  ];

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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Toko Saya"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Saya")
        ],
      ),
    );
  }
}

class Page1 extends StatelessWidget { 
  const Page1({super.key}); 
  @override
  Widget build(BuildContext context) { 
    return SafeArea( 
      child: Scaffold( 
        appBar: AppBar(
          title: Text(
            "BERANDA",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xFF122C4F),
          actions: [
            IconButton(
              onPressed: () {
                print("cart");
              },
              icon: Icon(Icons.shopping_cart, color: Colors.white)
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2
                )
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  print("menyari");
                }, 
                icon: Icon(Icons.person, color: Colors.white)
              )
            )
          ],
        ),
        body: Text("Home page", style: TextStyle(fontSize: 28)) 
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
        body: Text("Profil Saya", style: TextStyle(fontSize: 28),) 
      ), 
    ); 
  } 
}
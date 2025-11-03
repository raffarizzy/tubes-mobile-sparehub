import 'package:flutter/material.dart';

class Lacak extends StatelessWidget {
  final List<Map<String, dynamic>> pengiriman = [
    {
      'kode': 'TRX001234',
      'produk': 'Cover Rack Black New Vario 125',
      'status': 'Dalam Pengiriman',
      'tanggal': '01 Nov 2025',
    },
    {
      'kode': 'TRX001235',
      'produk': 'Part Motor #1526',
      'status': 'Diproses',
      'tanggal': '02 Nov 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2C54),
        title: Text('Lacak Produk', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: pengiriman.length,
        itemBuilder: (context, index) {
          final item = pengiriman[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['kode'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0B2C54),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['status'] == 'Dalam Pengiriman' 
                            ? Colors.orange.shade100 
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: item['status'] == 'Dalam Pengiriman' 
                              ? Colors.orange.shade900 
                              : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  item['produk'],
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Tanggal: ${item['tanggal']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

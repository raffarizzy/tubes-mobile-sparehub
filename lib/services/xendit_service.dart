import 'dart:convert';
import 'package:http/http.dart' as http;

class XenditService {
  static Future<String> createInvoice({
    required int amount,
    required String name,
    required String email,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3000/create-invoice');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'amount': amount, 'name': name, 'email': email}),
          )
          .timeout(const Duration(seconds: 20));

      // ✅ Kalau server error
      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.body}");
      }

      final data = jsonDecode(response.body);

      // ✅ Jangan biarkan null lolos
      if (data['invoice_url'] == null ||
          data['invoice_url'].toString().isEmpty) {
        throw Exception("Gagal mendapatkan invoice URL dari server");
      }

      return data['invoice_url'];
    } catch (e) {
      throw Exception("Request gagal: $e");
    }
  }
}

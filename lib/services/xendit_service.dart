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
            body: jsonEncode({
              'amount': amount,
              'name': name,
              'email': email,
              'successRedirectUrl': 'sparehub://payment/success',
              'failureRedirectUrl': 'sparehub://payment/failed',
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.body}");
      }

      final data = jsonDecode(response.body);

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
